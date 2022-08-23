import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/data/send.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mutiny/widgets/key_value.dart';
import 'package:mutiny/widgets/super_safe_area.dart';

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

    return SuperSafeArea(
        appBar: PlnAppBar(
            accentColor: green,
            title: "CONFIRM SEND",
            closeAction: () => context.go("/")),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KeyValue(k: "WHO", v: "satoshis.place"),
                  spacer12,
                  KeyValue(
                      k: "HOW MUCH",
                      v: send?.amountSats != null
                          ? "${send?.amountSats} sats"
                          : ""),
                  spacer12,
                  KeyValue(k: "INVOICE", v: send?.invoice ?? "no invoice..."),
                  spacer12,
                  KeyValue(k: "WHAT FOR", v: send?.description ?? "For drugs"),
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
            ]));
  }
}
