import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grpc/grpc.dart';
import 'package:pln/data/send.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/textField.dart';

import 'package:pln/generated/pln.pbgrpc.dart';

Future<void> test() async {
  try {
    final response = await plnClient.getStatus(
      GetStatusRequest(),
      // options: CallOptions(compression: const GzipCodec()),
    );
    debugPrint('Running?: ${response.running}');
  } catch (e) {
    debugPrint('Caught error: $e');
  }
  // await channel.shutdown();
}

class SendScreen extends ConsumerWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceTextController = TextEditingController();
    final sendNotifier = ref.read(sendProvider.notifier);

    _create() async {
      await sendNotifier
          .createSend(Send(invoice: invoiceTextController.text))
          .then((_) {
        debugPrint("creating... ${invoiceTextController.text}");
        context.go("/send/confirm");
      });
    }

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
                      BlandTextField(
                        controller: invoiceTextController,
                        prompt: "Paste Invoice",
                        iconData: Icons.qr_code,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Continue",
                              onPressed: () async {
                                await _create();
                              }),
                          const BlandButton(text: "Test", onPressed: test)
                        ],
                      )
                    ]))));
  }
}
