import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/constants.dart';
import 'package:mutiny/data/channel.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mutiny/widgets/key_value.dart';
import 'package:mutiny/widgets/super_safe_area.dart';

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
    final channelStreamProvider = ref.watch(channelStatusStreamProvider);

    return SuperSafeArea(
        appBar: PlnAppBar(
            accentColor: blue,
            title: channel?.status == "good"
                ? "CHANNEL OPENED!"
                : "OPENING CHANNEL...",
            closeAction: () => context.go("/")),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              channelStreamProvider.when(
                  data: (data) => KeyValue(
                      k: "Channel Open Status",
                      v: data ?? "no status something went wrong?"),
                  loading: () => const KeyValue(
                      k: "Channel Open Status",
                      vw: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(),
                      )),
                  error: (err, _) =>
                      KeyValue(k: "Channel Open Status", v: err.toString())),
              const SizedBox(height: 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlandButton(
                    text: channel?.status == "good"
                        ? "Nice"
                        : "Let me go home this is boring",
                    onPressed: () {
                      channelNotifier.clear();
                      context.go("/");
                    },
                  )
                ],
              )
            ]));
  }
}
