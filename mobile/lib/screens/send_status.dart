import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/send.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/key_value.dart';
import "package:pln/utility/capitalize.dart";

final sendStatusStreamProvider = StreamProvider<String?>((ref) {
  Stream<String?> getStatus() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      await ref.read(sendProvider.notifier).checkPaymentStatus();
      yield ref.read(sendProvider)?.sendStatus;
    }
  }

  return getStatus();
  // while (true) {
  //   await Future.delayed(Duration(seconds: 1));
  //   yield random.nextDouble();
  // }

  // ref.watch(sendProvider).asyncMap((value) => value ?? ""),
});

class SendStatus extends ConsumerWidget {
  const SendStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusProvider = ref.watch(sendStatusStreamProvider);
    final send = ref.watch(sendProvider);
    final sendNotifier = ref.read(sendProvider.notifier);

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Sending...", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KeyValue(
                              k: send?.sendStatus?.capitalize() ?? "Status",
                              v: "..."),
                          statusProvider.when(
                              data: (data) => Text(data ?? "nope"),
                              loading: () => const CircularProgressIndicator(),
                              error: (err, _) => Text(err.toString()))
                        ],
                      ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BlandButton(
                          //   text: "Poll",
                          //   onPressed: _checkPayment,
                          //   // onPressed: _sendPayment,
                          // )
                        ],
                      )
                    ]))));
  }
}
