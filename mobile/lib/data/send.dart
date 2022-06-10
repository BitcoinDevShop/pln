import 'package:flutter/foundation.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:riverpod/riverpod.dart';

import '../grpc.dart';

@immutable
class Send {
  const Send({required this.invoice, this.sendStatus});

  // final int amountSats;
  final String? invoice;
  final String? sendStatus;

  // // Since Receive is immutable, we implement a method that allows cloning the
  // // Receive with slightly different content.
  Send copyWith({String? invoice, String? sendStatus}) {
    return Send(
      sendStatus: sendStatus ?? this.sendStatus,
      invoice: invoice ?? this.invoice,
    );
  }
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier() : super(null);

  createSend(Send send) async {
    debugPrint("creating send...");
    state = send;
  }

  pay(Send send) async {
    try {
      debugPrint("paying...");
      final response = await plnClient.sendPayment(
        SendPaymentRequest(invoice: send.invoice),
      );
      debugPrint('Send res: ${response}');
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
