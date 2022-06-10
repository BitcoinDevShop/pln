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
use lightning_background_processor::BackgroundProcessor;
use macaroon::Macaroon;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::atomic::Ordering;
use std::{collections::hash_map::Entry, fs, sync::Arc};
use tokio::sync::{broadcast, Mutex};
use tokio::task::JoinHandle;
use uuid::Uuid;

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
    /*
pub data_dir: String,
pub config: Arc<SenseiConfig>,
pub node_directory: NodeDirectory,
pub database: Arc<SenseiDatabase>,
pub chain_manager: Arc<SenseiChainManager>,
pub event_sender: broadcast::Sender<SenseiEvent>,
pub available_ports: Arc<Mutex<VecDeque<u16>>>,
pub network_graph: Arc<Mutex<SenseiNetworkGraph>>,
*/}

impl ManagerService {
    pub async fn new(/*
        data_dir: &str,
        config: SenseiConfig,
        database: SenseiDatabase,
        chain_manager: Arc<SenseiChainManager>,
        event_sender: broadcast::Sender<SenseiEvent>,
        */) -> Self {
        /*
        let mut used_ports = HashSet::new();
        let mut available_ports = VecDeque::new();
        database
            .list_ports_in_use()
            .await
            .unwrap()
            .into_iter()
            .for_each(|port| {
                used_ports.insert(port);
            });

        for port in config.port_range_min..config.port_range_max {
            if !used_ports.contains(&port) {
                available_ports.push_back(port);
            }
        }
        */

        Self {
            /*
            data_dir: String::from(data_dir),
            config: Arc::new(config),
            node_directory: Arc::new(Mutex::new(HashMap::new())),
            database: Arc::new(database),
            chain_manager,
            event_sender,
            available_ports: Arc::new(Mutex::new(available_ports)),
            network_graph: Arc::new(Mutex::new(SenseiNetworkGraph {
                graph: None,
                msg_handler: None,
            })),
            */
        }
    }
}

#[derive(Serialize, Debug)]
pub enum Error {
    Generic(String),
}

/*
impl From<std::io::Error> for Error {
    fn from(e: std::io::Error) -> Self {
        Self::Generic(e.to_string())
    }
}

impl From<SenseiError> for Error {
    fn from(e: SenseiError) -> Self {
        Self::Generic(e.to_string())
    }
}
*/

impl ManagerService {
    pub async fn call(&self, request: ManagerRequest) -> Result<ManagerResponse, Error> {
        match request {
            ManagerRequest::GetStatus {} => {
                /*
                let root_node = self.database.get_root_node().await?;
                match root_node {
                    Some(_root_node) => {
                        let pubkey_node = self.database.get_node_by_pubkey(&pubkey).await?;
                        match pubkey_node {
                            Some(pubkey_node) => {
                                let directory = self.node_directory.lock().await;
                                let node_running = directory.contains_key(&pubkey);

                                Ok(ManagerResponse::GetStatus { running: true })
                            }
                            None => Ok(ManagerResponse::GetStatus { running: false }),
                        }
                    }
                    None => Ok(ManagerResponse::GetStatus { running: false }),
                }
                */
                Ok(ManagerResponse::GetStatus { running: true })
            }
            ManagerRequest::OpenChannel {
                pubkey,
                connection_string,
                amt_satoshis,
            } => Ok(ManagerResponse::OpenChannel {
                id: "123".to_string(),
                address: "bc123456".to_string(),
            }),
            ManagerRequest::GetChannel { id } => Ok(ManagerResponse::GetChannel {
                status: "good".to_string(),
            }),
            ManagerRequest::SendPayment { invoice } => Ok(ManagerResponse::SendPayment {
                status: "pending".to_string(),
            }),
            ManagerRequest::SendStatus { invoice } => Ok(ManagerResponse::SendPayment {
                status: "good".to_string(),
            }),
            ManagerRequest::GetBalance {} => Ok(ManagerResponse::GetBalance {
                amt_satoshis: 100_000,
            }),
        }
    }
}
