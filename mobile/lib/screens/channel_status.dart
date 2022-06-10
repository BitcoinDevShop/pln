import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/channel.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:qr_flutter/qr_flutter.dart';

final channelStatusStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getStatus() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(channelProvider.notifier).checkChannelStatus();
      final status = ref.read(channelProvider)?.status;
      if (status == "good") {
        shouldPoll = false;
        yield status;
      } else {
        yield status;
      }
    }
  }

  return getStatus();
});

class ChannelStatus extends ConsumerWidget {
  const ChannelStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.read(channelProvider);
    final channelNotifier = ref.read(channelProvider.notifier);
    final channelWatch = ref.watch(channelProvider);

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
                      const SizedBox(height: 24),
                      Text(channelWatch?.status ?? "..."),
                      // const Text("..."),
                      // channelWatch.when(
                      //   data: (data) {
                      //     return Text(data.toString());
                      //   },
                      //   error: (e, stack) {
                      //     return Text('$e');
                      //   },
                      //   loading: () => const CircularProgressIndicator(),
                      // ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Let me go home this is boring",
                            onPressed: () {
                              channelNotifier.clear();
                              context.go("/");
                            },
                          )
                        ],
                      )
                    ]))));
  }
}
