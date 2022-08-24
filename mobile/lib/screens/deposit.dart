import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/constants.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mutiny/widgets/super_safe_area.dart';
import 'package:mutiny/widgets/text_field.dart';

import '../data/channel.dart';

class DepositScreen extends ConsumerWidget {
  const DepositScreen({Key? key}) : super(key: key);

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
        context.go("/errormodal", extra: e);
      }
    }

    return SuperSafeArea(
        appBar: PlnAppBar(
            accentColor: blue,
            title: "DEPOSIT",
            closeAction: () => context.go("/")),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24.0),
              Column(
                children: [
                  Text(
                      "Every deposit opens a new Lightning channel.\n\nEnter an amount and the node you'd like to open a channel with.",
                      style: Theme.of(context).textTheme.headline2),
                  spacer24,
                  BlandTextField(
                      accentColor: blue,
                      controller: targetNodeTextController,
                      prompt: "Target Node",
                      iconData: Icons.memory),
                  const SizedBox(
                    height: 12,
                  ),
                  BlandTextField(
                    accentColor: blue,
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
                    text: "CONTINUE",
                    onPressed: _create,
                  )
                ],
              )
            ]));
  }
}
