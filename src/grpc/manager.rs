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
use super::pln::{
    GetBalanceRequest, GetBalanceResponse, GetChannelRequest, GetChannelResponse, GetStatusRequest,
    GetStatusResponse, OpenChannelRequest, OpenChannelResponse, SendPaymentRequest,
    SendPaymentResponse, SendStatusRequest, SendStatusResponse,
};
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

impl From<OpenChannelRequest> for ManagerRequest {
    fn from(req: OpenChannelRequest) -> Self {
        ManagerRequest::OpenChannel {
            pubkey: req.pubkey,
            connection_string: req.connection_string,
            amt_satoshis: req.amt_satoshis,
        }
    }
}

impl From<GetChannelRequest> for ManagerRequest {
    fn from(req: GetChannelRequest) -> Self {
        ManagerRequest::GetChannel { id: req.id }
    }
}

impl From<SendPaymentRequest> for ManagerRequest {
    fn from(req: SendPaymentRequest) -> Self {
        ManagerRequest::SendPayment {
            invoice: req.invoice,
        }
    }
}

impl From<SendStatusRequest> for ManagerRequest {
    fn from(req: SendStatusRequest) -> Self {
        ManagerRequest::SendStatus {
            invoice: req.invoice,
        }
    }
}

impl From<GetBalanceRequest> for ManagerRequest {
    fn from(req: GetBalanceRequest) -> Self {
        ManagerRequest::GetBalance {}
    }
}

impl TryFrom<ManagerResponse> for OpenChannelResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::OpenChannel { id, address } => Ok(Self { id, address }),
            _ => Err("impossible".to_string()),
        }
    }
}

impl TryFrom<ManagerResponse> for GetChannelResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::GetChannel { status } => Ok(Self { status }),
            _ => Err("impossible".to_string()),
        }
    }
}

impl TryFrom<ManagerResponse> for SendPaymentResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::SendPayment { status } => Ok(Self { status }),
            _ => Err("impossible".to_string()),
        }
    }
}

impl TryFrom<ManagerResponse> for SendStatusResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::SendStatus { status } => Ok(Self { status }),
            _ => Err("impossible".to_string()),
        }
    }
}

impl TryFrom<ManagerResponse> for GetBalanceResponse {
    type Error = String;

    fn try_from(res: ManagerResponse) -> Result<Self, Self::Error> {
        match res {
            ManagerResponse::GetBalance { amt_satoshis } => Ok(Self { amt_satoshis }),
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

    async fn open_channel(
        &self,
        request: tonic::Request<OpenChannelRequest>,
    ) -> Result<tonic::Response<OpenChannelResponse>, tonic::Status> {
        let request: ManagerRequest = request.into_inner().into();
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<OpenChannelResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }

    async fn get_channel(
        &self,
        request: tonic::Request<GetChannelRequest>,
    ) -> Result<tonic::Response<GetChannelResponse>, tonic::Status> {
        let request: ManagerRequest = request.into_inner().into();
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<GetChannelResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }

    async fn send_payment(
        &self,
        request: tonic::Request<SendPaymentRequest>,
    ) -> Result<tonic::Response<SendPaymentResponse>, tonic::Status> {
        let request: ManagerRequest = request.into_inner().into();
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<SendPaymentResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }

    async fn send_status(
        &self,
        request: tonic::Request<SendStatusRequest>,
    ) -> Result<tonic::Response<SendStatusResponse>, tonic::Status> {
        let request: ManagerRequest = request.into_inner().into();
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<SendStatusResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }

    async fn get_balance(
        &self,
        request: tonic::Request<GetBalanceRequest>,
    ) -> Result<tonic::Response<GetBalanceResponse>, tonic::Status> {
        let request: ManagerRequest = request.into_inner().into();
        match self.manager_service.call(request).await {
            Ok(response) => {
                let response: Result<GetBalanceResponse, String> = response.try_into();
                response
                    .map(Response::new)
                    .map_err(|_err| tonic::Status::unknown("err"))
            }
            Err(_err) => Err(tonic::Status::unknown("error")),
        }
    }
}
