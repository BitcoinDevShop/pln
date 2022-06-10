import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/send.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/key_value.dart';

import 'constants.dart';

class SendStatus extends ConsumerWidget {
  const SendStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendProvider);
    // final sendNotifier = ref.read(sendProvider.notifier);

    // Future<void> _sendPayment() async {
    //   await sendNotifier.pay(const Send(invoice: "abc123")).then((_) {
    //     context.go("/send/status");
    //   });
    // }

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
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KeyValue(k: send?.sendStatus ?? "Status", v: "..."),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Send",
                            // onPressed: _sendPayment,
                          )
                        ],
                      )
                    ]))));
  }
}
