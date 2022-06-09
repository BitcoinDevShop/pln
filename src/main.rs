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

use senseicore::{
    chain::{bitcoind_client::BitcoindClient, manager::SenseiChainManager},
    config::SenseiConfig,
    database::SenseiDatabase,
    events::SenseiEvent,
    services::admin::{AdminRequest, AdminResponse, AdminService},
};

// use plncore::services::admin::{AdminRequest, AdminResponse, AdminService};
use plncore::services::manager::{ManagerRequest, ManagerResponse, ManagerService};

use entity::sea_orm::{self, ConnectOptions};
use migration::{Migrator, MigratorTrait};
use sea_orm::Database;

//use crate::http::admin::add_routes as add_admin_routes;
//use crate::http::node::add_routes as add_node_routes;

use ::http::{
    header::{self, ACCEPT, AUTHORIZATION, CONTENT_TYPE, COOKIE},
    Method, Uri,
};
use axum::{
    body::{boxed, Full},
    extract::Extension,
    handler::Handler,
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::get,
    Router,
};
use clap::Parser;

use rust_embed::RustEmbed;

use grpc::manager::{ManagerServer, ManagerService as GrpcManagerService};
/*
use grpc::node::{NodeServer, NodeService as GrpcNodeService};
*/
use std::net::SocketAddr;
use std::time::Duration;
use tower_cookies::CookieManagerLayer;

use std::fs;
use std::sync::Arc;
use tonic::transport::Server;
use tower_http::cors::{CorsLayer, Origin};

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
fn main() {
    env_logger::init();
    macaroon::initialize().expect("failed to initialize macaroons");
    let args = SenseiArgs::parse();

    let sensei_dir = match args.data_dir {
        Some(dir) => dir,
        None => {
            let home_dir = dirs::home_dir().unwrap_or_else(|| ".".into());
            format!("{}/.sensei", home_dir.to_str().unwrap())
        }
    };

    fs::create_dir_all(&sensei_dir).expect("failed to create data directory");

    let root_config_path = format!("{}/config.json", sensei_dir);
    let mut root_config = SenseiConfig::from_file(root_config_path, None);

    if let Some(network) = args.network {
        root_config.set_network(network.parse::<bitcoin::Network>().unwrap());
    }

    fs::create_dir_all(format!("{}/{}", sensei_dir, root_config.network))
        .expect("failed to create network directory");

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
        .build()
        .unwrap();
    let persistence_runtime_handle = persistence_runtime.handle().clone();

    let sensei_runtime = Builder::new_multi_thread()
        .worker_threads(20)
        .thread_name("sensei")
        .enable_all()
        .build()
        .unwrap();

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

        let admin_service = Arc::new(
            AdminService::new(
                &sensei_dir,
                config.clone(),
                database,
                chain_manager,
                event_sender,
            )
            .await,
        );

        let manager_service = Arc::new(ManagerService::new().await);

        // get a root node if already created
        let get_node_req = match admin_service
            .call(AdminRequest::StartAdmin {
                passphrase: String::from("password"),
            })
            .await
        {
            Ok(resp) => {
                let found_node = match resp {
                    AdminResponse::StartAdmin {
                        pubkey,
                        macaroon,
                        token,
                    } => {
                        let directory = admin_service.node_directory.lock().await;
                        let handle = directory.get(&pubkey).unwrap().as_ref().unwrap();
                        Some(handle.node.clone())
                    }
                    _ => None,
                };
                found_node
            }
            Err(_) => None,
        };

        // Create a node if we do not have one already
        let root_node = match get_node_req {
            Some(node) => node,
            None => {
                let new_node = match admin_service
                    .call(AdminRequest::CreateAdmin {
                        username: String::from("root"),
                        alias: String::from("root"),
                        passphrase: String::from("password"),
                        start: true,
                    })
                    .await
                    .unwrap()
                {
                    AdminResponse::CreateAdmin {
                        pubkey,
                        macaroon,
                        id,
                        token,
                        role,
                    } => {
                        let directory = admin_service.node_directory.lock().await;
                        let handle = directory.get(&pubkey).unwrap().as_ref().unwrap();
                        Some(handle.node.clone())
                    }
                    _ => None,
                }
                .unwrap();
                new_node
            }
        };

        // got a node!
        println!("node: {}", root_node.get_pubkey());

        let router = Router::new();
        //.route("/admin/*path", static_handler.into_service()) // TODO none of these routes
        //.fallback(get(not_found));

        /*
        let router = add_admin_routes(router);
        let router = add_node_routes(router);

        let router = match args.development_mode {
            Some(_development_mode) => router.layer(
                CorsLayer::new()
                    .allow_headers(vec![AUTHORIZATION, ACCEPT, COOKIE, CONTENT_TYPE])
                    .allow_credentials(true)
                    .allow_origin(Origin::list(vec![
                        "http://localhost:3001".parse().unwrap(),
                        "http://localhost:5401".parse().unwrap(),
                    ]))
                    .allow_methods(vec![
                        Method::GET,
                        Method::POST,
                        Method::OPTIONS,
                        Method::DELETE,
                        Method::PUT,
                        Method::PATCH,
                    ]),
            ),
            None => router,
        };
        */

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

        println!("yay");

        println!(
            "manage your sensei node at http://{}:{}/admin/nodes",
            config.api_host.clone(),
            port
        );

        if let Err(e) = server.await {
            eprintln!("server error: {}", e);
        }
    });
}

// We use a wildcard matcher ("/static/*file") to match against everything
// within our defined assets directory. This is the directory on our Asset
// struct below, where folder = "examples/public/".
/*
async fn static_handler(uri: Uri) -> impl IntoResponse {
    let mut path = uri.path().trim_start_matches('/').to_string();

    if path.starts_with("admin/static/") {
        path = path.replace("admin/static/", "static/");
    } else {
        path = String::from("index.html");
    }

    StaticFile(path)
}

// Finally, we use a fallback route for anything that didn't match.
async fn not_found() -> Html<&'static str> {
    Html("<h1>404</h1><p>Not Found</p>")
}
*/

/*
#[derive(RustEmbed)]
#[folder = "web-admin/build/"]
struct Asset;

pub struct StaticFile<T>(pub T);

impl<T> IntoResponse for StaticFile<T>
where
    T: Into<String>,
{
    fn into_response(self) -> Response {
        let path = self.0.into();

        match Asset::get(path.as_str()) {
            Some(content) => {
                let body = boxed(Full::from(content.data));
                let mime = mime_guess::from_path(path).first_or_octet_stream();
                Response::builder()
                    .header(header::CONTENT_TYPE, mime.as_ref())
                    .body(body)
                    .unwrap()
            }
            None => Response::builder()
                .status(StatusCode::NOT_FOUND)
                .body(boxed(Full::from("404")))
                .unwrap(),
        }
    }
}
*/
