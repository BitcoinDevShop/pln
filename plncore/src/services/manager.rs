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

use senseicore::services::node::{NodeRequest, OpenChannelRequest};
use senseicore::services::PaginationRequest;
use serde::Serialize;
use std::sync::Arc;
use std::time::Duration;

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
    ListChannels {},
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
    ListChannels { channels: Vec<Channel> },
    Error(Error),
}

#[derive(Serialize)]
pub struct Channel {
    pub node_alias: String,
    pub total_amt_satoshis: u64,
    pub balance_amt_satoshis: u64,
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
                let internal_channel_id: u64 = rng.gen();

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
                                onchain_balance_sats,
                                channel_balance_msats,
                                ..
                            } => {
                                let total = onchain_balance_sats + channel_balance_msats / 1000;
                                dbg!(total);
                                Some(total)
                            }
                            _ => None,
                        };

                        if balance.is_some() && balance.unwrap() >= amt_satoshis {
                            // Once getting funding, open channel with that node
                            // TODO delete
                            println!("funding complete haha");

                            // TODO set new custom_id field and use that for lookups
                            let channel = OpenChannelRequest {
                                counterparty_pubkey: pubkey.clone(),
                                counterparty_host_port: Some(connection_string),
                                amount_sats: balance.unwrap() - 1000, // TODO better fees
                                public: false,
                                scid_alias: Some(true),
                                custom_id: Some(internal_channel_id),
                                push_amount_msats: Some(0),
                                forwarding_fee_proportional_millionths: None,
                                forwarding_fee_base_msat: None,
                                cltv_expiry_delta: None,
                                max_dust_htlc_exposure_msat: None,
                                force_close_avoidance_max_fee_satoshis: None,
                            };
                            let channel_req = NodeRequest::OpenChannels {
                                requests: vec![channel.clone()],
                            };

                            let channel_resp = node_spawn.call(channel_req).await.unwrap();
                            let _channel_id = match channel_resp {
                                senseicore::services::node::NodeResponse::OpenChannels {
                                    requests: _,
                                    results,
                                } => Some(results[0].channel_id.clone().unwrap()),
                                _ => None,
                            }
                            .unwrap();

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
                // for each node in our pubkey list, check the channel status
                let id_int = id.parse::<u64>().unwrap();
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
                    let channel_status = match channel_resp {
                        senseicore::services::node::NodeResponse::ListChannels {
                            channels,
                            pagination: _,
                        } => {
                            let mut status = "not_found";
                            for channel in channels {
                                if channel.clone().user_channel_id == id_int {
                                    if channel.is_channel_ready {
                                        status = "good";
                                    } else {
                                        status = "pending";
                                    }
                                }
                            }
                            Some(status)
                        }
                        _ => None,
                    };

                    // if no good or pending status, then go to next node
                    if let Some(status) = channel_status {
                        if status == "good" {
                            return Ok(ManagerResponse::GetChannel {
                                status: "good".to_string(),
                            });
                        } else if status == "pending" {
                            return Ok(ManagerResponse::GetChannel {
                                status: "pending".to_string(),
                            });
                        }
                    }
                }

                Ok(ManagerResponse::GetChannel {
                    status: "pending".to_string(),
                })
            }
            ManagerRequest::ListChannels {} => {
                // for each node in our pubkey list, get the channels
                let mut total_channels: Vec<Channel> = vec![];
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
                    match channel_resp {
                        senseicore::services::node::NodeResponse::ListChannels {
                            channels,
                            pagination: _,
                        } => {
                            for channel in channels {
                                total_channels.push(Channel {
                                    node_alias: channel.counterparty_pubkey,
                                    total_amt_satoshis: channel.channel_value_satoshis,
                                    balance_amt_satoshis: channel.balance_msat / 1000,
                                })
                            }
                        }
                        _ => {}
                    };
                }

                Ok(ManagerResponse::ListChannels {
                    channels: total_channels,
                })
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
                            onchain_balance_sats,
                            channel_balance_msats,
                            ..
                        } => onchain_balance_sats + channel_balance_msats / 1000,
                        _ => 0,
                    };
                    amt_satoshis += balance;
                }

                Ok(ManagerResponse::GetBalance { amt_satoshis })
            }
        }
    }
}
