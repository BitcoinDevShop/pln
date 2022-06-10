///
//  Generated code. Do not modify.
//  source: pln.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'pln.pb.dart' as $0;
export 'pln.pb.dart';

class ManagerClient extends $grpc.Client {
  static final _$getStatus =
      $grpc.ClientMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
          '/pln.Manager/GetStatus',
          ($0.GetStatusRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetStatusResponse.fromBuffer(value));
  static final _$openChannel =
      $grpc.ClientMethod<$0.OpenChannelRequest, $0.OpenChannelResponse>(
          '/pln.Manager/OpenChannel',
          ($0.OpenChannelRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.OpenChannelResponse.fromBuffer(value));
  static final _$getChannel =
      $grpc.ClientMethod<$0.GetChannelRequest, $0.GetChannelResponse>(
          '/pln.Manager/GetChannel',
          ($0.GetChannelRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetChannelResponse.fromBuffer(value));
  static final _$sendPayment =
      $grpc.ClientMethod<$0.SendPaymentRequest, $0.SendPaymentResponse>(
          '/pln.Manager/SendPayment',
          ($0.SendPaymentRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.SendPaymentResponse.fromBuffer(value));
  static final _$sendStatus =
      $grpc.ClientMethod<$0.SendStatusRequest, $0.SendStatusResponse>(
          '/pln.Manager/SendStatus',
          ($0.SendStatusRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.SendStatusResponse.fromBuffer(value));
  static final _$getBalance =
      $grpc.ClientMethod<$0.GetBalanceRequest, $0.GetBalanceResponse>(
          '/pln.Manager/GetBalance',
          ($0.GetBalanceRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetBalanceResponse.fromBuffer(value));

  ManagerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetStatusResponse> getStatus(
      $0.GetStatusRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.OpenChannelResponse> openChannel(
      $0.OpenChannelRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$openChannel, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetChannelResponse> getChannel(
      $0.GetChannelRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChannel, request, options: options);
  }

  $grpc.ResponseFuture<$0.SendPaymentResponse> sendPayment(
      $0.SendPaymentRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendPayment, request, options: options);
  }

  $grpc.ResponseFuture<$0.SendStatusResponse> sendStatus(
      $0.SendStatusRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBalanceResponse> getBalance(
      $0.GetBalanceRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalance, request, options: options);
  }
}

abstract class ManagerServiceBase extends $grpc.Service {
  $core.String get $name => 'pln.Manager';

  ManagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStatusRequest.fromBuffer(value),
        ($0.GetStatusResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.OpenChannelRequest, $0.OpenChannelResponse>(
            'OpenChannel',
            openChannel_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.OpenChannelRequest.fromBuffer(value),
            ($0.OpenChannelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetChannelRequest, $0.GetChannelResponse>(
        'GetChannel',
        getChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetChannelRequest.fromBuffer(value),
        ($0.GetChannelResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SendPaymentRequest, $0.SendPaymentResponse>(
            'SendPayment',
            sendPayment_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SendPaymentRequest.fromBuffer(value),
            ($0.SendPaymentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendStatusRequest, $0.SendStatusResponse>(
        'SendStatus',
        sendStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendStatusRequest.fromBuffer(value),
        ($0.SendStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBalanceRequest, $0.GetBalanceResponse>(
        'GetBalance',
        getBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBalanceRequest.fromBuffer(value),
        ($0.GetBalanceResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetStatusResponse> getStatus_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetStatusRequest> request) async {
    return getStatus(call, await request);
  }

  $async.Future<$0.OpenChannelResponse> openChannel_Pre($grpc.ServiceCall call,
      $async.Future<$0.OpenChannelRequest> request) async {
    return openChannel(call, await request);
  }

  $async.Future<$0.GetChannelResponse> getChannel_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetChannelRequest> request) async {
    return getChannel(call, await request);
  }

  $async.Future<$0.SendPaymentResponse> sendPayment_Pre($grpc.ServiceCall call,
      $async.Future<$0.SendPaymentRequest> request) async {
    return sendPayment(call, await request);
  }

  $async.Future<$0.SendStatusResponse> sendStatus_Pre($grpc.ServiceCall call,
      $async.Future<$0.SendStatusRequest> request) async {
    return sendStatus(call, await request);
  }

  $async.Future<$0.GetBalanceResponse> getBalance_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetBalanceRequest> request) async {
    return getBalance(call, await request);
  }

  $async.Future<$0.GetStatusResponse> getStatus(
      $grpc.ServiceCall call, $0.GetStatusRequest request);
  $async.Future<$0.OpenChannelResponse> openChannel(
      $grpc.ServiceCall call, $0.OpenChannelRequest request);
  $async.Future<$0.GetChannelResponse> getChannel(
      $grpc.ServiceCall call, $0.GetChannelRequest request);
  $async.Future<$0.SendPaymentResponse> sendPayment(
      $grpc.ServiceCall call, $0.SendPaymentRequest request);
  $async.Future<$0.SendStatusResponse> sendStatus(
      $grpc.ServiceCall call, $0.SendStatusRequest request);
  $async.Future<$0.GetBalanceResponse> getBalance(
      $grpc.ServiceCall call, $0.GetBalanceRequest request);
}
