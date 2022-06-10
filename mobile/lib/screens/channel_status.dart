import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/channel.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:qr_flutter/qr_flutter.dart';

class ChannelStatus extends ConsumerWidget {
  const ChannelStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.read(channelProvider);

    final channelFutureProvider = FutureProvider<String>(
      (ref) async {
        await Future.delayed(const Duration(milliseconds: 200));
        final response = await plnClient
            .getChannel(GetChannelRequest(id: channel?.id)); // our future
        return response.status; //returns a list of all the hospitals
      },
    );

    _refresh() async {
      ref.refresh(channelFutureProvider);
    }

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Creating Channel...",
                closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      const Text("..."),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Poll",
                            onPressed: _refresh,
                          )
                        ],
                      )
                    ]))));
  }
}
