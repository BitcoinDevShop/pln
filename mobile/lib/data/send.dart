import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:riverpod/riverpod.dart';

import '../grpc.dart';

@immutable
class Send {
  const Send({required this.invoice, this.sendStatus});

  final String? invoice;
  final String? sendStatus;

  Send copyWith({String? invoice, String? sendStatus}) {
    return Send(
      sendStatus: sendStatus ?? this.sendStatus,
      invoice: invoice ?? this.invoice,
    );
  }
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier() : super(null);

  createSendState(Send send) async {
    debugPrint("creating send...");
    state = send;
  }

  pay() async {
    try {
      debugPrint("paying...");
      final response = await plnClient.sendPayment(
        SendPaymentRequest(invoice: state?.invoice),
      );
      debugPrint('Send res: $response');
      state = state?.copyWith(sendStatus: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  checkPayment() async {
    try {
      final response = await plnClient
          .sendStatus(SendStatusRequest(invoice: state?.invoice));
      debugPrint('Send status res: $response');
      state = state?.copyWith(sendStatus: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  clear() {
    state = null;
  }
}

final sendProvider = StateNotifierProvider<SendNotifier, Send?>((ref) {
  return SendNotifier();
});
