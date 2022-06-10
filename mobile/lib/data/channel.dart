import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:riverpod/riverpod.dart';

import 'package:fixnum/fixnum.dart' show Int64;

import '../grpc.dart';

@immutable
class Channel {
  const Channel(
      {required this.amountSats,
      required this.pubkey,
      required this.connectionString,
      this.id,
      this.fundingAddress,
      this.status});

  final int amountSats;
  final String pubkey;
  final String connectionString;
  // From the open response
  final String? id;
  final String? fundingAddress;
  // From the status response
  final String? status;

  // TODO
  Channel copyWith({String? id, String? fundingAddress, String? status}) {
    return Channel(
        amountSats: amountSats,
        pubkey: pubkey,
        connectionString: connectionString,
        id: id ?? this.id,
        fundingAddress: fundingAddress ?? this.fundingAddress,
        status: status ?? this.status);
  }
}

class ChannelNotifier extends StateNotifier<Channel?> {
  ChannelNotifier() : super(null);

  Timer? _timer;

  createChannelState(Channel channel) async {
    debugPrint("creating channel...");
    state = channel;
  }

  openChannel() async {
    try {
      debugPrint("creating channel...");
      final response = await plnClient.openChannel(OpenChannelRequest(
          pubkey: state?.pubkey,
          connectionString: state?.connectionString,
          amtSatoshis: Int64(state?.amountSats ?? 0)));
      debugPrint("create channel response: $response");
      state =
          state?.copyWith(fundingAddress: response.address, id: response.id);
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  checkChannelStatus() async {
    try {
      final response =
          await plnClient.getChannel(GetChannelRequest(id: state?.id));
      debugPrint("check channel response: $response");
      state = state?.copyWith(status: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  // https://github.com/herveGuigoz/adb_connect/blob/5c685906e0d200ddba0a40e1ad5ff166733c98a1/lib/modules/devices/logic/adb_service.dart
  startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (_) async {
      if (state?.status != "bad") {
        await checkChannelStatus();
      } else {
        _timer?.cancel();
      }
      ;
    });
  }

  clear() {
    _timer?.cancel();
    state = null;
  }

  // TODO this isn't run when we nav away from channels, so figure out a way to run it
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final channelProvider = StateNotifierProvider<ChannelNotifier, Channel?>((ref) {
  return ChannelNotifier();
});
