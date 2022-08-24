import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/constants.dart';
import 'package:mutiny/data/send.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mutiny/widgets/qr_scanner.dart';
import 'package:mutiny/widgets/super_safe_area.dart';
import 'package:mutiny/widgets/text_field.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceTextController = TextEditingController();
    final sendNotifier = ref.read(sendProvider.notifier);

    Future<void> tryDecode(String data) async {
      try {
        await sendNotifier.createSendFromInvoice(data).then((_) {
          debugPrint("creating... $data");
          context.go("/send/confirm");
        });
      } catch (e) {
        debugPrint('Caught error: $e');
        context.go("/errormodal", extra: e);
      }
    }

    // TODO is it right that I'm defining the function in here?
    void onDetect(Barcode barcode) async {
      final data = barcode.code;
      if (data != null) {
        debugPrint('Barcode found! $data');
        await tryDecode(data.trim());
      }
    }

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
        context.go("/errormodal", extra: e);
      }
    }

    return SuperSafeArea(
        appBar: PlnAppBar(
            accentColor: green,
            title: "SEND",
            closeAction: () => context.go("/")),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: QRViewExample(onDetect: onDetect)),
              ),
              spacer24,
              BlandTextField(
                accentColor: green,
                controller: invoiceTextController,
                prompt: "Paste Invoice",
                iconData: Icons.qr_code,
              ),
              spacer24,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlandButton(
                      text: "CONTINUE",
                      onPressed: () async {
                        await _create();
                      }),
                ],
              )
            ]));
  }
}
