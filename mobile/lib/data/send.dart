import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutiny/generated/pln.pbgrpc.dart';
import 'package:riverpod/riverpod.dart';

import 'package:bolt11_decoder/bolt11_decoder.dart';

import '../grpc.dart';

@immutable
class Send {
  const Send(
      {required this.invoice,
      this.sendStatus,
      this.amountSats,
      this.description});

  final String? invoice;
  final String? sendStatus;
  final int? amountSats;
  final String? description;
  final bool shouldPoll = false;

  Send copyWith(
      {String? invoice,
      String? sendStatus,
      String? description,
      int? amountSats}) {
    return Send(
        sendStatus: sendStatus ?? this.sendStatus,
        invoice: invoice ?? this.invoice,
        description: description ?? this.description,
        amountSats: amountSats ?? this.amountSats);
  }
}

int btcToSats(btc) {
  return (btc.toDouble() * 100000000).toInt();
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier(this.ref) : super(null);

  final Ref ref;

  createSendFromInvoice(String invoice) async {
    final trimmed = invoice.replaceAll("lightning:", "");

    final req = Bolt11PaymentRequest(trimmed);
    debugPrint("amount: ${(req.amount.toDouble() * 100000000).toInt()}");

    var description = "";
    for (var t in req.tags) {
      debugPrint("${t.type}: ${t.data}");
      if (t.type == "description") {
        description = t.data;
      }
    }
    state = Send(
        invoice: trimmed,
        amountSats: btcToSats(req.amount),
        description: description);
  }

  createSendState(Send send) async {
    debugPrint("creating send...");
    state = send;
  }

  pay() async {
    final plnClient = ref.read(plnClientProvider)!;
    try {
      debugPrint("paying...");
      final response = await plnClient.sendPayment(
        SendPaymentRequest(invoice: state?.invoice),
      );
      debugPrint('Send res: $response');
      state = state?.copyWith(sendStatus: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
      throw Exception(e.toString());
    }
  }

  checkPaymentStatus() async {
    final plnClient = ref.read(plnClientProvider)!;
    try {
      debugPrint("checking status for ${state?.invoice}");
      final response = await plnClient
          .sendStatus(SendStatusRequest(invoice: state?.invoice));
      debugPrint('Send status res: $response');
      state = state?.copyWith(sendStatus: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
      throw Exception(e.toString());
    }
  }

  // shouldPoll() async {
  //   state = state.copyWith(shouldPoll: true);
  // }

  // shouldPoll() async {
  //   state = state.copyWith(shouldPoll: true);
  // }
}

final sendProvider = StateNotifierProvider<SendNotifier, Send?>((ref) {
  return SendNotifier(ref);
});
