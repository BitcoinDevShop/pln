// This file is Copyright its original authors, visible in version control
// history.
//
// This file is licensed under the Apache License, Version 2.0 <LICENSE-APACHE
// or http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your option.
// You may not use this file except in accordance with one or both of these
// licenses.

/*
use crate::chain::manager::SenseiChainManager;
use crate::database::SenseiDatabase;
use crate::error::Error as SenseiError;
use crate::events::SenseiEvent;
use crate::network_graph::SenseiNetworkGraph;
use crate::{config::SenseiConfig, hex_utils, node::LightningNode, version};
*/

use entity::node::{self, NodeRole};
use entity::sea_orm::{ActiveModelTrait, ActiveValue, EntityTrait};
use entity::{access_token, seconds_since_epoch};
use futures::stream::{self, StreamExt};
use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};

use lightning_background_processor::BackgroundProcessor;
use macaroon::Macaroon;
use senseicore::services::node::{NodeRequest, OpenChannelInfo};
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::atomic::Ordering;
use std::time::Duration;
use std::{collections::hash_map::Entry, fs, sync::Arc};
use tokio::sync::{broadcast, Mutex};
use tokio::task::JoinHandle;
use uuid::Uuid;

use senseicore::services::admin::{AdminRequest, AdminResponse, AdminService};

pub enum ManagerRequest {
    GetStatus {},
    OpenChannel {
        pubkey: String,
        connection_string: String,
        amt_satoshis: u64,
    },
    GetChannel {
        id: String,
    },
    SendPayment {
        invoice: String,
    },
    SendStatus {
        invoice: String,
    },
    GetBalance {},
}

#[derive(Serialize)]
#[serde(untagged)]
pub enum ManagerResponse {
    GetStatus { running: bool },
    OpenChannel { id: String, address: String },
    GetChannel { status: String },
    SendPayment { status: String },
    SendStatus { status: String },
    GetBalance { amt_satoshis: u64 },
    Error(Error),
}

#[derive(Clone)]
pub struct ManagerService {
    pub admin_service: Arc<AdminService>,
    pub root_node_pubkey: String,
}

impl ManagerService {
    pub async fn new(admin_service: Arc<AdminService>, root_node_pubkey: String) -> Self {
        Self {
            admin_service,
            root_node_pubkey,
        }
    }
}

#[derive(Serialize, Debug)]
pub enum Error {
    Generic(String),
}

impl From<std::io::Error> for Error {
    fn from(e: std::io::Error) -> Self {
        Self::Generic(e.to_string())
    }
}

/*
impl From<senseicore::SenseiError> for Error {
    fn from(e: SenseiError) -> Self {
        Self::Generic(e.to_string())
    }
}
*/

impl From<macaroon::MacaroonError> for Error {
    fn from(_e: macaroon::MacaroonError) -> Self {
        Self::Generic(String::from("macaroon error"))
    }
}

impl From<migration::DbErr> for Error {
    fn from(e: migration::DbErr) -> Self {
        Self::Generic(e.to_string())
    }
}

impl ManagerService {
    pub async fn call(&self, request: ManagerRequest) -> Result<ManagerResponse, Error> {
        match request {
            ManagerRequest::GetStatus {} => {
                let root_node = self.admin_service.database.get_root_node().await.unwrap(); // TODO dont unwrap
                match root_node {
                    Some(_root_node) => {
                        let pubkey_node = self
                            .admin_service
                            .database
                            .get_node_by_pubkey(self.root_node_pubkey.as_str())
                            .await
                            .unwrap(); // TODO dont unwrap
                        match pubkey_node {
                            Some(_pubkey_node) => {
                                let directory = self.admin_service.node_directory.lock().await;
                                let node_running =
                                    directory.contains_key(self.root_node_pubkey.as_str());

                                Ok(ManagerResponse::GetStatus {
                                    running: node_running,
                                })
                            }
                            None => Ok(ManagerResponse::GetStatus { running: false }),
                        }
                    }
                    None => Ok(ManagerResponse::GetStatus { running: false }),
                }
            }
            // TODO
            ManagerRequest::OpenChannel {
                pubkey,
                connection_string,
                amt_satoshis,
            } => {
                // First create a new node
                let username = String::from_utf8(
                    thread_rng()
                        .sample_iter(&Alphanumeric)
                        .take(10)
                        .collect::<Vec<_>>(),
                )
                .unwrap();
                let alias = String::from_utf8(
                    thread_rng()
                        .sample_iter(&Alphanumeric)
                        .take(8)
                        .collect::<Vec<_>>(),
                )
                .unwrap();

                let create_node_req = AdminRequest::CreateNode {
                    username,
                    alias,
                    passphrase: "password".to_string(),
                    start: true,
                };
                let create_node_resp = self.admin_service.call(create_node_req).await.unwrap(); // TODO do not unwrap
                let new_node = match create_node_resp {
                    AdminResponse::CreateNode {
                        pubkey,
                        macaroon,
                        listen_addr,
                        listen_port,
                        id,
                    } => {
                        // get the node back from the db
                        let db_node = self
                            .admin_service
                            .database
                            .get_node_by_pubkey(pubkey.as_str())
                            .await
                            .unwrap(); // TODO dont unwrap, but should have
                        db_node
                    }
                    _ => None,
                }
                .unwrap();

                // Then get an address for the node
                let node_directory = self.admin_service.node_directory.lock().await;
                let node = match node_directory.get(&new_node.pubkey) {
                    Some(Some(node_handle)) => Ok(node_handle.node.clone()),
                    _ => Err("node not found"),
                }
                .unwrap();

                let node_req = NodeRequest::GetUnusedAddress {};
                let address_resp = node.call(node_req).await.unwrap();
                let address = match address_resp {
                    senseicore::services::node::NodeResponse::GetUnusedAddress { address } => {
                        Ok(address)
                    }
                    _ => Err("some error"),
                }
                .unwrap();

                // TODO make an ID for the temp channel to map to?

                // Loop through waiting for funding
                let node_spawn = node.clone();
                tokio::spawn(async move {
                    let mut interval = tokio::time::interval(Duration::from_secs(5));
                    loop {
                        interval.tick().await;
                        let balance_req = NodeRequest::GetBalance {};
                        let balance_resp = node_spawn.call(balance_req).await.unwrap();
                        let balance = match balance_resp {
                            senseicore::services::node::NodeResponse::GetBalance {
                                balance_satoshis,
                            } => Some(balance_satoshis),
                            _ => None,
                        };

                        if balance.is_some() && balance.unwrap() >= amt_satoshis {
                            // Once getting funding, open channel with that node
                            // TODO delete
                            println!("funding complete haha");

                            let channel = OpenChannelInfo {
                                node_connection_string: format!("{}@{}", pubkey, connection_string),
                                amt_satoshis: balance.unwrap() - 1000, // TODO better fees
                                public: false,
                            };
                            let channel_req = NodeRequest::OpenChannels {
                                channels: vec![channel],
                            };

                            let channel_resp = node_spawn.call(channel_req).await.unwrap();
                            let channel_id = match channel_resp {
                                senseicore::services::node::NodeResponse::OpenChannels {
                                    channels,
                                    results,
                                } => Some(results[0].temp_channel_id.clone().unwrap()),
                                _ => None,
                            };
                            println!("channel_id: {}", channel_id.unwrap());
                            return;
                        }
                        // TODO delete
                        println!("funding not complete :(");
                    }
                });

                // Return the response
                Ok(ManagerResponse::OpenChannel {
                    id: "123".to_string(),
                    address,
                })
            }
            // TODO
            ManagerRequest::GetChannel { id } => Ok(ManagerResponse::GetChannel {
                status: "good".to_string(),
            }),
            // TODO
            ManagerRequest::SendPayment { invoice } => Ok(ManagerResponse::SendPayment {
                status: "pending".to_string(),
            }),
            // TODO
            ManagerRequest::SendStatus { invoice } => Ok(ManagerResponse::SendPayment {
                status: "good".to_string(),
            }),
            // TODO
            ManagerRequest::GetBalance {} => Ok(ManagerResponse::GetBalance {
                amt_satoshis: 100_000,
            }),
        }
    }
}
