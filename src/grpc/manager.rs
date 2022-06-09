// This file is Copyright its original authors, visible in version control
// history.
//
// This file is licensed under the Apache License, Version 2.0 <LICENSE-APACHE
// or http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your option.
// You may not use this file except in accordance with one or both of these
// licenses.

use std::sync::Arc;

pub use super::pln::manager_server::{Manager, ManagerServer};
use super::pln::{GetStatusRequest, GetStatusResponse};
use plncore::services::manager::{ManagerRequest, ManagerResponse};
use tonic::{metadata::MetadataMap, Response, Status};

/*
impl From<entity::access_token::Model> for Token {
    fn from(access_token: entity::access_token::Model) -> Token {
        Token {
            id: access_token.id,
            created_at: access_token.created_at,
            updated_at: access_token.updated_at,
            expires_at: access_token.expires_at,
            token: access_token.token,
            name: access_token.name,
            single_use: access_token.single_use,
            scope: access_token.scope,
        }
    }
}
*/

impl TryFrom<ManagerResponse> for GetStatusResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::GetStatus { running } => Ok(Self { running }),
            _ => Err("impossible".to_string()),
        }
    }
}

pub struct ManagerService {
    pub manager_service: Arc<plncore::services::manager::ManagerService>,
}

/*
pub fn get_scope_from_request(request: &ManagerRequest) -> Option<&'static str> {
    match request {
        ManagerRequest::CreateNode { .. } => Some("nodes/create"),
        ManagerRequest::ListNodes { .. } => Some("nodes/list"),
        ManagerRequest::DeleteNode { .. } => Some("nodes/delete"),
        ManagerRequest::StopNode { .. } => Some("nodes/stop"),
        ManagerRequest::ListTokens { .. } => Some("tokens/list"),
        ManagerRequest::CreateToken { .. } => Some("tokens/create"),
        ManagerRequest::DeleteToken { .. } => Some("tokens/delete"),
        _ => None,
    }
}
*/

impl ManagerService {
    /*
    async fn is_valid_token(&self, token: String, scope: Option<&str>) -> bool {
        let access_token = self
            .manager_service
            .database
            .get_access_token_by_token(token)
            .await;

        match access_token {
            Ok(Some(access_token)) => {
                if access_token.is_valid(scope) {
                    if access_token.single_use {
                        self.manager_service
                            .database
                            .delete_access_token(access_token.id)
                            .await
                            .unwrap();
                    }
                    true
                } else {
                    false
                }
            }
            Ok(None) => false,
            Err(_) => false,
        }
    }

    async fn authenticated_request(
        &self,
        metadata: MetadataMap,
        request: ManagerRequest,
    ) -> Result<ManagerResponse, tonic::Status> {
        // let required_scope = get_scope_from_request(&request);

        let token = self.raw_token_from_metadata(metadata)?;

        if self.is_valid_token(token, required_scope).await {
            self.manager_service
                .call(request)
                .await
                .map_err(|_e| Status::unknown("error"))
        } else {
            Err(Status::not_found("invalid or expired access token"))
        }
    }

    fn raw_token_from_metadata(&self, metadata: MetadataMap) -> Result<String, tonic::Status> {
        let token = metadata.get("token");

        if token.is_none() {
            return Err(Status::unauthenticated("token is required"));
        }

        token
            .unwrap()
            .to_str()
            .map(String::from)
            .map_err(|_e| Status::unauthenticated("invalid token: must be ascii"))
    }
    */
}

#[tonic::async_trait]
impl Manager for ManagerService {
    async fn get_status(
        &self,
        _request: tonic::Request<GetStatusRequest>,
    ) -> Result<tonic::Response<GetStatusResponse>, tonic::Status> {
        /*
        let macaroon_hex_string = raw_macaroon_from_metadata(request.metadata().clone())?;

        let (_macaroon, session) = utils::macaroon_with_session_from_hex_str(&macaroon_hex_string)
            .map_err(|_e| tonic::Status::unauthenticated("invalid macaroon"))?;
        let pubkey = session.pubkey.clone();

        */
        let request = ManagerRequest::GetStatus {};
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<GetStatusResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }
}
