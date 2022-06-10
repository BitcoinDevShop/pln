import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/send.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/key_value.dart';

import '../constants.dart';

class SendConfirm extends ConsumerWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendProvider);
    final sendNotifier = ref.read(sendProvider.notifier);

    Future<void> _sendPayment() async {
      await sendNotifier.pay().then((_) {
        context.go("/send/status");
      });
    }

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Confirm Send", closeAction: () => context.go("/")),
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
                          const KeyValue(k: "Amount", v: "1000 sats"),
                          const SizedBox(height: 12),
                          KeyValue(
                              k: "Invoice",
                              v: send?.invoice ?? "no invoice..."),
                          const SizedBox(height: 12),
                          const KeyValue(k: "Memo", v: "For drugs"),
                          const SizedBox(height: 12),
                          Container(
                              color: lime,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Memos can be bad sometimes!"),
                              ))
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Send",
                            onPressed: _sendPayment,
                          )
                        ],
                      )
                    ]))));
  }
}
