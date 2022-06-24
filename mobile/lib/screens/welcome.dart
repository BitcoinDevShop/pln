import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/grpc.dart';
import 'package:pln/main.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:pln/widgets/text_field.dart';

class Welcome extends ConsumerWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpointTextController = TextEditingController();
    final prefsNotifier = ref.read(prefProvider.notifier);
    final plnClient = ref.read(plnClientProvider.notifier);

    _connect() async {
      try {
        await prefsNotifier.update(endpointTextController.text).then((_) async {
          debugPrint("updating endpoint: ${endpointTextController.text}");
          try {
            await plnClient.restartClient().then((_) => context.go("/"));
          } catch (e) {
            throw ("couldn't connect using ${endpointTextController.text}");
          }
        });
      } catch (e) {
        debugPrint('Caught error: $e');
      }
    }

    final endpoint = ref.read(prefProvider);

    return SafeArea(
        child: Scaffold(
            appBar: const PlnAppBar(title: "Welcome"),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandTextField(
                            controller: endpointTextController,
                            prompt: "Paste gRPC endpoint",
                            iconData: Icons.add_link,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                              "current endpoint: ${endpoint ?? "no endpoint set"}"),
                        ],
                      ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Connect",
                              onPressed: () async {
                                await _connect();
                              }),
                        ],
                      )
                    ]))));
  }
}
