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

use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};

use senseicore::services::node::{NodeRequest, OpenChannelInfo};
use senseicore::services::PaginationRequest;
use serde::Serialize;
use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;

use senseicore::services::admin::{AdminRequest, AdminResponse, AdminService};

pub enum ManagerRequest {
    GetStatus {},
    StartNodes {},
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
    StartNodes {},
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
    internal_channel_id_map: Arc<Mutex<HashMap<String, String>>>,
}

impl ManagerService {
    pub async fn new(admin_service: Arc<AdminService>, root_node_pubkey: String) -> Self {
        Self {
            admin_service,
            root_node_pubkey,
            internal_channel_id_map: Arc::new(Mutex::new(HashMap::new())),
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
            ManagerRequest::StartNodes {} => {
                println!("Trying to start all nodes...");
                let get_nodes_req = AdminRequest::ListNodes {
                    pagination: PaginationRequest::default(),
                };
                let get_node_resp = self.admin_service.call(get_nodes_req).await.unwrap(); // TODO do not unwrap
                let pubkeys: Vec<String> = match get_node_resp {
                    AdminResponse::ListNodes {
                        nodes,
                        pagination: _,
                    } => Some(nodes.into_iter().map(|node| node.pubkey).collect()),
                    _ => None,
                }
                .unwrap();
                for node_pubkey in pubkeys {
                    println!("Starting node: {}", node_pubkey.as_str());
                    let pubkey = node_pubkey.to_string();
                    let start_node_req = AdminRequest::StartNode {
                        pubkey,
                        passphrase: "password".to_string(),
                    };
                    let create_node_resp = self.admin_service.call(start_node_req).await.unwrap(); // TODO do not unwrap
                    match create_node_resp {
                        AdminResponse::StartNode { macaroon: _ } => {
                            println!("Started node: {}", node_pubkey.as_str());
                            ()
                        }
                        _ => println!("Could not start node: {}", node_pubkey.as_str()),
                    }
                }
                Ok(ManagerResponse::StartNodes {})
            }
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
                        macaroon: _,
                        listen_addr: _,
                        listen_port: _,
                        id: _,
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

                // make an ID for the temp channel to map to?
                let mut rng = rand::thread_rng();
                let internal_channel_id: u16 = rng.gen();
                let internal_channel_id_copy = Arc::new(internal_channel_id);
                let map = self.internal_channel_id_map.clone();

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
                            } => {
                                dbg!(balance_satoshis);
                                Some(balance_satoshis)
                            }
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
                                    channels: _,
                                    results,
                                } => Some(results[0].temp_channel_id.clone().unwrap()),
                                _ => None,
                            }
                            .unwrap();

                            // TODO map channel id to an internal id
                            println!("channel_id: {}", channel_id);
                            map.lock()
                                .await
                                .insert(internal_channel_id_copy.to_string(), channel_id);
                            return;
                        }
                        // TODO delete
                        println!("funding not complete :(");
                    }
                });

                // Return the response
                Ok(ManagerResponse::OpenChannel {
                    id: internal_channel_id.clone().to_string(),
                    address,
                })
            }
            ManagerRequest::GetChannel { id } => {
                // find the id in the map
                let channel_map = self.internal_channel_id_map.lock().await;
                let channel_id = channel_map.get(&id);
                if let Some(_chan_id) = channel_id {
                    // for each node in our pubkey list, check the channel status
                    let node_directory = self.admin_service.node_directory.lock().await;
                    for (_node_pubkey, node_handle) in node_directory.iter() {
                        let node = match node_handle {
                            Some(node) => Some(node.node.clone()),
                            None => None,
                        }
                        .unwrap();

                        // now go check channel id status
                        let channel_req = NodeRequest::ListChannels {
                            pagination: PaginationRequest {
                                page: 0,
                                take: 100,
                                query: None,
                            },
                        };
                        let channel_resp = node.call(channel_req).await.unwrap();
                        let channel_result = match channel_resp {
                            senseicore::services::node::NodeResponse::ListChannels {
                                channels,
                                pagination: _,
                            } => {
                                dbg!(channels.clone());
                                for channel in channels {
                                    /*
                                    dbg!(channel.channel_id.clone());
                                    dbg!(String::from(chan_id));
                                    dbg!(channel.channel_id.clone() == String::from(chan_id));
                                    if channel.channel_id == String::from(chan_id) {
                                        if channel.is_funding_locked {
                                            return Ok(ManagerResponse::GetChannel {
                                                status: "good".to_string(),
                                            });
                                        }
                                    }
                                    */

                                    // TODO only looking for single channel
                                    // sense I can't come back and look for
                                    // channel id based on temporary sensei id
                                    if channel.is_funding_locked {
                                        return Ok(ManagerResponse::GetChannel {
                                            status: "good".to_string(),
                                        });
                                    }
                                    continue;
                                }
                                return Ok(ManagerResponse::GetChannel {
                                    status: "pending".to_string(),
                                });
                            }
                            _ => Some(ManagerResponse::GetChannel {
                                status: "pending".to_string(),
                            }),
                        };

                        if channel_result.is_some() {
                            return Ok(channel_result.unwrap());
                        }
                    }

                    Ok(ManagerResponse::GetChannel {
                        status: "pending".to_string(),
                    })
                } else {
                    Ok(ManagerResponse::GetChannel {
                        status: "pending".to_string(),
                    })
                }
            }
            ManagerRequest::SendPayment { invoice } => {
                // for each node in our pubkey list, attempt payment
                let node_directory = self.admin_service.node_directory.lock().await;
                for (_node_pubkey, node_handle) in node_directory.iter() {
                    let node = match node_handle {
                        Some(node) => Some(node.node.clone()),
                        None => None,
                    }
                    .unwrap();

                    let send_payment_req = NodeRequest::SendPayment {
                        invoice: invoice.clone(),
                    };
                    let payment_resp = node.call(send_payment_req).await;

                    // Don't fail if couldn't send, try next node in loop
                    if let Ok(send_payment_resp) = payment_resp {
                        let status = match send_payment_resp {
                            senseicore::services::node::NodeResponse::SendPayment {} => "pending",
                            _ => "bad",
                        };
                        if status == "pending" {
                            return Ok(ManagerResponse::SendPayment {
                                status: "pending".to_string(),
                            });
                        }
                    }
                }

                Ok(ManagerResponse::SendPayment {
                    status: "bad".to_string(),
                })
            }
            // TODO
            ManagerRequest::SendStatus { invoice: _ } => Ok(ManagerResponse::SendStatus {
                status: "good".to_string(),
            }),
            ManagerRequest::GetBalance {} => {
                // get the amount from each of the nodes we have saved
                let mut amt_satoshis = 0;

                // for each node in our pubkey list, check the channel status
                let node_directory = self.admin_service.node_directory.lock().await;
                for (_node_pubkey, node_handle) in node_directory.iter() {
                    let node = match node_handle {
                        Some(node) => Some(node.node.clone()),
                        None => None,
                    }
                    .unwrap();

                    let balance_req = NodeRequest::GetBalance {};
                    let balance_resp = node.call(balance_req).await.unwrap();
                    let balance = match balance_resp {
                        senseicore::services::node::NodeResponse::GetBalance {
                            balance_satoshis,
                        } => balance_satoshis,
                        _ => 0,
                    };
                    amt_satoshis += balance;
                }

                Ok(ManagerResponse::GetBalance { amt_satoshis })
            }
        }
    }
}
