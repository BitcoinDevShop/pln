// This file is Copyright its original authors, visible in version control
// history.
//
// This file is licensed under the Apache License, Version 2.0 <LICENSE-APACHE
// or http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your option.
// You may not use this file except in accordance with one or both of these
// licenses.

mod grpc;
//mod http;
mod hybrid;

use anyhow::{Context, Result};

use senseicore::{
    chain::{bitcoind_client::BitcoindClient, manager::SenseiChainManager},
    config::SenseiConfig,
    database::SenseiDatabase,
    events::SenseiEvent,
    services::admin::{AdminRequest, AdminResponse, AdminService},
};

use plncore::services::manager::{ManagerRequest, ManagerResponse, ManagerService};

use plnentity::sea_orm::{self, ConnectOptions};
use plnmigration::{Migrator, MigratorTrait};
use sea_orm::Database;

use axum::{extract::Extension, Router};
use clap::Parser;

use grpc::manager::{ManagerServer, ManagerService as GrpcManagerService};
use std::time::Duration;
use tower_cookies::CookieManagerLayer;

use std::fs;
use std::sync::Arc;

use std::{
    net::SocketAddr,
    sync::atomic::{AtomicBool, Ordering},
};
use tonic::transport::Server;

use tokio::runtime::Builder;
use tokio::sync::broadcast;
use tokio::sync::mpsc::Sender;

/// Sensei daemon
#[derive(Parser, Debug)]
#[clap(version)]
struct SenseiArgs {
    /// Sensei data directory, defaults to home directory
    #[clap(long, env = "DATA_DIR")]
    data_dir: Option<String>,
    #[clap(long, env = "NETWORK")]
    network: Option<String>,
    #[clap(long, env = "BITCOIND_RPC_HOST")]
    bitcoind_rpc_host: Option<String>,
    #[clap(long, env = "BITCOIND_RPC_PORT")]
    bitcoind_rpc_port: Option<u16>,
    #[clap(long, env = "BITCOIND_RPC_USERNAME")]
    bitcoind_rpc_username: Option<String>,
    #[clap(long, env = "BITCOIND_RPC_PASSWORD")]
    bitcoind_rpc_password: Option<String>,
    #[clap(long, env = "DEVELOPMENT_MODE")]
    development_mode: Option<bool>,
    #[clap(long, env = "PORT_RANGE_MIN")]
    port_range_min: Option<u16>,
    #[clap(long, env = "PORT_RANGE_MAX")]
    port_range_max: Option<u16>,
    #[clap(long, env = "API_HOST")]
    api_host: Option<String>,
    #[clap(long, env = "API_PORT")]
    api_port: Option<u16>,
    #[clap(long, env = "DATABASE_URL")]
    database_url: Option<String>,
}

pub type ManagerRequestResponse = (ManagerRequest, Sender<ManagerResponse>);
fn main() -> Result<()> {
    env_logger::init();
    macaroon::initialize().expect("failed to initialize macaroons");
    let args = SenseiArgs::parse();

    let stop_signal = Arc::new(AtomicBool::new(false));

    for term_signal in signal_hook::consts::TERM_SIGNALS {
        signal_hook::flag::register(*term_signal, Arc::clone(&stop_signal)).unwrap();
    }

    let sensei_dir = if let Some(dir) = args.data_dir {
        dir
    } else {
        let home_dir = dirs::home_dir().unwrap_or_else(|| ".".into());
        format!(
            "{}/.sensei",
            home_dir.to_str().context("invalid home dir string")?
        )
    };

    fs::create_dir_all(&sensei_dir).expect("failed to create data directory");

    let root_config_path = format!("{}/config.json", sensei_dir);
    let mut root_config = SenseiConfig::from_file(root_config_path, None);

    if let Some(network) = args.network {
        root_config.set_network(
            network
                .parse::<bitcoin::Network>()
                .context("invalid network arg")?,
        );
    }

    fs::create_dir_all(format!("{}/{}", sensei_dir, root_config.network))
        .context("failed to create network directory")?;

    let network_config_path = format!("{}/{}/config.json", sensei_dir, root_config.network);
    let mut config = SenseiConfig::from_file(network_config_path, Some(root_config));

    // override config with command line arguments or ENV vars
    if let Some(bitcoind_rpc_host) = args.bitcoind_rpc_host {
        config.bitcoind_rpc_host = bitcoind_rpc_host
    }
    if let Some(bitcoind_rpc_port) = args.bitcoind_rpc_port {
        config.bitcoind_rpc_port = bitcoind_rpc_port
    }
    if let Some(bitcoind_rpc_username) = args.bitcoind_rpc_username {
        config.bitcoind_rpc_username = bitcoind_rpc_username
    }
    if let Some(bitcoind_rpc_password) = args.bitcoind_rpc_password {
        config.bitcoind_rpc_password = bitcoind_rpc_password
    }
    if let Some(port_range_min) = args.port_range_min {
        config.port_range_min = port_range_min;
    }
    if let Some(port_range_max) = args.port_range_max {
        config.port_range_max = port_range_max;
    }
    if let Some(api_port) = args.api_port {
        config.api_port = api_port;
    }
    if let Some(api_host) = args.api_host {
        config.api_host = api_host;
    }
    if let Some(database_url) = args.database_url {
        config.database_url = database_url;
    }

    if !config.database_url.starts_with("postgres:") && !config.database_url.starts_with("mysql:") {
        let sqlite_path = format!("{}/{}/{}", sensei_dir, config.network, config.database_url);
        config.database_url = format!("sqlite://{}?mode=rwc", sqlite_path);
    }

    let persistence_runtime = Builder::new_multi_thread()
        .worker_threads(20)
        .thread_name("persistence")
        .enable_all()
        .build()?;

    let persistence_runtime_handle = persistence_runtime.handle().clone();

    let sensei_runtime = Builder::new_multi_thread()
        .worker_threads(20)
        .thread_name("sensei")
        .enable_all()
        .build()?;

    sensei_runtime.block_on(async move {
        let (event_sender, _event_receiver): (
            broadcast::Sender<SenseiEvent>,
            broadcast::Receiver<SenseiEvent>,
        ) = broadcast::channel(1024);

        let mut db_connection_options = ConnectOptions::new(config.database_url.clone());
        db_connection_options
            .max_connections(100)
            .min_connections(10)
            .connect_timeout(Duration::new(30, 0));
        let db_connection = Database::connect(db_connection_options).await.unwrap();
        Migrator::up(&db_connection, None)
            .await
            .expect("failed to run migrations");

        let database = SenseiDatabase::new(db_connection, persistence_runtime_handle);
        database.mark_all_nodes_stopped().await.unwrap();

        let addr = SocketAddr::from(([0, 0, 0, 0], config.api_port));

        let bitcoind_client = Arc::new(
            BitcoindClient::new(
                config.bitcoind_rpc_host.clone(),
                config.bitcoind_rpc_port,
                config.bitcoind_rpc_username.clone(),
                config.bitcoind_rpc_password.clone(),
                tokio::runtime::Handle::current(),
            )
            .await
            .expect("invalid bitcoind rpc config"),
        );

        let chain_manager = Arc::new(
            SenseiChainManager::new(
                config.clone(),
                bitcoind_client.clone(),
                bitcoind_client.clone(),
                bitcoind_client,
            )
            .await
            .unwrap(),
        );

        let admin_service_stop_signal = stop_signal.clone();
        let admin_service = Arc::new(
            AdminService::new(
                &sensei_dir,
                config.clone(),
                database,
                chain_manager,
                event_sender,
                tokio::runtime::Handle::current(),
                admin_service_stop_signal,
            )
            .await,
        );

        // get a root node if already created
        let get_node_req = if let Ok(resp) = admin_service
            .call(AdminRequest::StartAdmin {
                passphrase: String::from("password"),
            })
            .await
        {
            let found_node = if let AdminResponse::StartAdmin {
                pubkey,
                macaroon: _,
                token: _,
            } = resp
            {
                let directory = admin_service.node_directory.lock().await;
                let handle = directory.get(&pubkey).unwrap().as_ref().unwrap();
                Some(handle.node.clone())
            } else {
                None
            };
            found_node
        } else {
            None
        };

        // Create a node if we do not have one already
        let root_node = if let Some(node) = get_node_req {
            node
        } else {
            let new_node = if let Ok(AdminResponse::CreateAdmin {
                pubkey,
                macaroon: _,
                id: _,
                token: _,
                role: _,
            }) = admin_service
                .call(AdminRequest::CreateAdmin {
                    username: String::from("root"),
                    alias: String::from("root"),
                    passphrase: String::from("password"),
                    start: true,
                })
                .await
            {
                let directory = admin_service.node_directory.lock().await;
                let handle = directory.get(&pubkey).unwrap().as_ref().unwrap();
                Some(handle.node.clone())
            } else {
                None
            }
            .unwrap();
            new_node
        };

        let manager_service =
            Arc::new(ManagerService::new(admin_service.clone(), root_node.get_pubkey()).await);

        // lets check if the node is running
        let status_res = manager_service
            .clone()
            .call(ManagerRequest::GetStatus {})
            .await
            .unwrap(); // TODO do not unwrap
        let status = match status_res {
            ManagerResponse::GetStatus { running } => running,
            _ => false,
        };

        // got a root node!
        println!("root node: {}, running: {}", root_node.get_pubkey(), status);

        // now start any nodes we have in our db
        let _start_res = manager_service
            .clone()
            .call(ManagerRequest::StartNodes {})
            .await;

        let router = Router::new();

        let port = match args.development_mode {
            Some(_) => String::from("3001"),
            None => format!("{}", config.api_port),
        };

        let http_service = router
            .layer(CookieManagerLayer::new())
            .layer(Extension(admin_service.clone()))
            .into_make_service();

        let grpc_service = Server::builder()
            .add_service(ManagerServer::new(GrpcManagerService {
                manager_service: manager_service.clone(),
            }))
            .into_service();

        let hybrid_service = hybrid::hybrid(http_service, grpc_service);

        let server = hyper::Server::bind(&addr).serve(hybrid_service);

        tokio::spawn(async move {
            if let Err(e) = server.await {
                eprintln!("server errored with: {:?}", e);
            }
        });

        println!(
            "manage your sensei node at http://{}:{}/admin/nodes",
            config.api_host.clone(),
            port
        );

        let mut interval = tokio::time::interval(Duration::from_millis(250));
        loop {
            interval.tick().await;
            if stop_signal.load(Ordering::Acquire) {
                let _res = admin_service.stop().await;
                break;
            }
        }
    });

    Ok(())
}
