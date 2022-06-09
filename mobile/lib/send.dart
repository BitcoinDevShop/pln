import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grpc/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/textField.dart';

import 'package:pln/generated/pln.pbgrpc.dart';

Future<void> test() async {
  final channel = ClientChannel(
    'localhost',
    port: 5401,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry:
          CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );
  final stub = ManagerClient(channel);

  // final name = args.isNotEmpty ? args[0] : 'world';

  try {
    final response = await stub.getStatus(
      GetStatusRequest(),
      // options: CallOptions(compression: const GzipCodec()),
    );
    debugPrint('Running?: ${response.running}');
  } catch (e) {
    debugPrint('Caught error: $e');
  }
  await channel.shutdown();
}

class Send extends ConsumerWidget {
  const Send({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "pLN - Send", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      const BlandTextField(
                        prompt: "Paste Invoice",
                        iconData: Icons.qr_code,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Continue",
                              onPressed: () => debugPrint("Pressed Continue")),
                          BlandButton(
                              text: "Test",
                              onPressed: () async {
                                test();
                              }),
                        ],
                      )
                    ]))));
  }
}
