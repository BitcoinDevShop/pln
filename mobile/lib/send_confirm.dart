import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/textField.dart';

import 'package:pln/generated/pln.pbgrpc.dart';

class SendConfirm extends ConsumerWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: Scaffold(
            appBar:
                PlnAppBar(title: "Send", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Amount\n1000 sats"),
                          SizedBox(height: 12),
                          Text("Invoice\nabc123... 123abc"),
                          SizedBox(height: 12),
                          Text("Memo\nfor drugs"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Send",
                              onPressed: () => debugPrint("Pressed Send")),
                        ],
                      )
                    ]))));
  }
}
