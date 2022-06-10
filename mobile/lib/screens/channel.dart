import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/text_field.dart';

import '../data/channel.dart';

class ChannelScreen extends ConsumerWidget {
  const ChannelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetNodeTextController = TextEditingController();
    final sizeTextController = TextEditingController();
    final channelNotifier = ref.read(channelProvider.notifier);

    _create() async {
      try {
        final amount = int.tryParse(sizeTextController.text);

        if (amount == null) {
          throw ("amount blank");
        }

        final splitTarget = targetNodeTextController.text.split('@');

        if (splitTarget.length != 2) {
          throw ("invalid target string");
        }

        final pubkey = splitTarget[0];
        final connectionString = splitTarget[1];

        await channelNotifier.createChannelState(Channel(
            amountSats: amount,
            pubkey: pubkey,
            connectionString: connectionString));
        await channelNotifier.openChannel().then((_) {
          context.go("/channel/fund");
        });
      } catch (e) {
        debugPrint('Caught error: $e');
      }
    }

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Open Channel", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24.0),
                      Column(
                        children: [
                          BlandTextField(
                              controller: targetNodeTextController,
                              prompt: "Target Node",
                              iconData: Icons.memory),
                          const SizedBox(
                            height: 12,
                          ),
                          BlandTextField(
                            controller: sizeTextController,
                            prompt: "How Much",
                            iconData: Icons.expand,
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Continue",
                            onPressed: _create,
                          )
                        ],
                      )
                    ]))));
  }
}
