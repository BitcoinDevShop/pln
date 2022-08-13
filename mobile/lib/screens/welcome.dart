import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/constants.dart';
import 'package:pln/grpc.dart';
import 'package:pln/main.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:pln/widgets/super_safe_area.dart';
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
        var newText = endpointTextController.text == ""
            ? "http://localhost:5401"
            : endpointTextController.text;
        await prefsNotifier.update(newText).then((_) async {
          debugPrint("updating endpoint: $newText");

          try {
            await plnClient.restartClient().then((_) => context.go("/"));
          } catch (e) {
            throw ("couldn't connect using $newText");
          }
        });
      } catch (e) {
        debugPrint('Caught error: $e');
      }
    }

    final endpoint = ref.read(prefProvider);

    return SuperSafeArea(
        appBar: const PlnAppBar(
          title: "Welcome",
          home: true,
          accentColor: red,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Connect to your Mutiny server to get started",
                      style: Theme.of(context).textTheme.headline1),
                  spacer24,
                  BlandTextField(
                    accentColor: blue,
                    controller: endpointTextController,
                    prompt: "Paste gRPC endpoint",
                    iconData: Icons.add_link,
                  ),
                  const SizedBox(height: 24.0),
                  Text("Current endpoint: ${endpoint ?? "no endpoint set"}",
                      style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
              const SizedBox(height: 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlandButton(
                      text: "CONNECT",
                      onPressed: () async {
                        await _connect();
                      }),
                ],
              )
            ]));
  }
}
