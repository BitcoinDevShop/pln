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
      this.fundingAddress});

  final int amountSats;
  final String pubkey;
  final String connectionString;
  // From the open response
  final String? id;
  final String? fundingAddress;

  // TODO
  Channel copyWith({required String id, required String fundingAddress}) {
    return Channel(
        amountSats: amountSats,
        pubkey: pubkey,
        connectionString: connectionString,
        id: id,
        fundingAddress: fundingAddress);
  }
}

class ChannelNotifier extends StateNotifier<Channel?> {
  ChannelNotifier() : super(null);

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
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  clear() {
    state = null;
  }
}

final channelProvider = StateNotifierProvider<ChannelNotifier, Channel?>((ref) {
  return ChannelNotifier();
});
