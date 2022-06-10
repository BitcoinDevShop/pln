///
//  Generated code. Do not modify.
//  source: pln.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use getStatusRequestDescriptor instead')
const GetStatusRequest$json = const {
  '1': 'GetStatusRequest',
};

/// Descriptor for `GetStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusRequestDescriptor = $convert.base64Decode('ChBHZXRTdGF0dXNSZXF1ZXN0');
@$core.Deprecated('Use getStatusResponseDescriptor instead')
const GetStatusResponse$json = const {
  '1': 'GetStatusResponse',
  '2': const [
    const {'1': 'running', '3': 1, '4': 1, '5': 8, '10': 'running'},
  ],
};

/// Descriptor for `GetStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusResponseDescriptor = $convert.base64Decode('ChFHZXRTdGF0dXNSZXNwb25zZRIYCgdydW5uaW5nGAEgASgIUgdydW5uaW5n');
@$core.Deprecated('Use openChannelRequestDescriptor instead')
const OpenChannelRequest$json = const {
  '1': 'OpenChannelRequest',
  '2': const [
    const {'1': 'pubkey', '3': 1, '4': 1, '5': 9, '10': 'pubkey'},
    const {'1': 'connection_string', '3': 2, '4': 1, '5': 9, '10': 'connectionString'},
    const {'1': 'amt_satoshis', '3': 3, '4': 1, '5': 4, '10': 'amtSatoshis'},
  ],
};

/// Descriptor for `OpenChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openChannelRequestDescriptor = $convert.base64Decode('ChJPcGVuQ2hhbm5lbFJlcXVlc3QSFgoGcHVia2V5GAEgASgJUgZwdWJrZXkSKwoRY29ubmVjdGlvbl9zdHJpbmcYAiABKAlSEGNvbm5lY3Rpb25TdHJpbmcSIQoMYW10X3NhdG9zaGlzGAMgASgEUgthbXRTYXRvc2hpcw==');
@$core.Deprecated('Use openChannelResponseDescriptor instead')
const OpenChannelResponse$json = const {
  '1': 'OpenChannelResponse',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `OpenChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openChannelResponseDescriptor = $convert.base64Decode('ChNPcGVuQ2hhbm5lbFJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZBIYCgdhZGRyZXNzGAIgASgJUgdhZGRyZXNz');
@$core.Deprecated('Use getChannelRequestDescriptor instead')
const GetChannelRequest$json = const {
  '1': 'GetChannelRequest',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChannelRequestDescriptor = $convert.base64Decode('ChFHZXRDaGFubmVsUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');
@$core.Deprecated('Use getChannelResponseDescriptor instead')
const GetChannelResponse$json = const {
  '1': 'GetChannelResponse',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `GetChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChannelResponseDescriptor = $convert.base64Decode('ChJHZXRDaGFubmVsUmVzcG9uc2USFgoGc3RhdHVzGAEgASgJUgZzdGF0dXM=');
@$core.Deprecated('Use sendPaymentRequestDescriptor instead')
const SendPaymentRequest$json = const {
  '1': 'SendPaymentRequest',
  '2': const [
    const {'1': 'invoice', '3': 1, '4': 1, '5': 9, '10': 'invoice'},
  ],
};

/// Descriptor for `SendPaymentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendPaymentRequestDescriptor = $convert.base64Decode('ChJTZW5kUGF5bWVudFJlcXVlc3QSGAoHaW52b2ljZRgBIAEoCVIHaW52b2ljZQ==');
@$core.Deprecated('Use sendPaymentResponseDescriptor instead')
const SendPaymentResponse$json = const {
  '1': 'SendPaymentResponse',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `SendPaymentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendPaymentResponseDescriptor = $convert.base64Decode('ChNTZW5kUGF5bWVudFJlc3BvbnNlEhYKBnN0YXR1cxgBIAEoCVIGc3RhdHVz');
@$core.Deprecated('Use sendStatusRequestDescriptor instead')
const SendStatusRequest$json = const {
  '1': 'SendStatusRequest',
  '2': const [
    const {'1': 'invoice', '3': 1, '4': 1, '5': 9, '10': 'invoice'},
  ],
};

/// Descriptor for `SendStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendStatusRequestDescriptor = $convert.base64Decode('ChFTZW5kU3RhdHVzUmVxdWVzdBIYCgdpbnZvaWNlGAEgASgJUgdpbnZvaWNl');
@$core.Deprecated('Use sendStatusResponseDescriptor instead')
const SendStatusResponse$json = const {
  '1': 'SendStatusResponse',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `SendStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendStatusResponseDescriptor = $convert.base64Decode('ChJTZW5kU3RhdHVzUmVzcG9uc2USFgoGc3RhdHVzGAEgASgJUgZzdGF0dXM=');
@$core.Deprecated('Use getBalanceRequestDescriptor instead')
const GetBalanceRequest$json = const {
  '1': 'GetBalanceRequest',
};

/// Descriptor for `GetBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceRequestDescriptor = $convert.base64Decode('ChFHZXRCYWxhbmNlUmVxdWVzdA==');
@$core.Deprecated('Use getBalanceResponseDescriptor instead')
const GetBalanceResponse$json = const {
  '1': 'GetBalanceResponse',
  '2': const [
    const {'1': 'amt_satoshis', '3': 1, '4': 1, '5': 4, '10': 'amtSatoshis'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode('ChJHZXRCYWxhbmNlUmVzcG9uc2USIQoMYW10X3NhdG9zaGlzGAEgASgEUgthbXRTYXRvc2hpcw==');
