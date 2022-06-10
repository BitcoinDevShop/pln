import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/send.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/text_field.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceTextController = TextEditingController();
    final sendNotifier = ref.read(sendProvider.notifier);

    _create() async {
      try {
        await sendNotifier
            .createSendFromInvoice(invoiceTextController.text)
            .then((_) {
          debugPrint("creating... ${invoiceTextController.text}");
          context.go("/send/confirm");
        });
      } catch (e) {
        debugPrint('Caught error: $e');
      }
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
                      const SizedBox(height: 24.0),
                      BlandTextField(
                        controller: invoiceTextController,
                        prompt: "Paste Invoice",
                        iconData: Icons.qr_code,
                      ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Continue",
                              onPressed: () async {
                                await _create();
                              }),
                        ],
                      )
                    ]))));
  }
}
