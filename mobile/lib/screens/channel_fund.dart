import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/channel.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:qr_flutter/qr_flutter.dart';

class ChannelFund extends ConsumerWidget {
  const ChannelFund({Key? key}) : super(key: key);

  static const address = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.read(channelProvider);

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Fund Channel", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QrImage(
                              padding: EdgeInsets.zero,
                              data: channel?.fundingAddress ?? "BAD",
                              version: QrVersions.auto,
                              // Screen width minus 40.0 for container and 48.0 for app padding
                              // size: MediaQuery.of(context).size.width - 88.0),
                              size: MediaQuery.of(context).size.width / 2),
                          const SizedBox(height: 12),
                          Text(channel?.fundingAddress ?? "BAD"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Continue",
                              onPressed: () => context.go("/channel/status")),
                        ],
                      )
                    ]))));
  }
}
