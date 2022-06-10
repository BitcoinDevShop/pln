import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/send.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/key_value.dart';

final sendStatusStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getStatus() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(sendProvider.notifier).checkPaymentStatus();
      final status = ref.read(sendProvider)?.sendStatus;
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

class SendStatus extends ConsumerWidget {
  const SendStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusProvider = ref.watch(sendStatusStreamProvider);
    final send = ref.watch(sendProvider);
    final sendNotifier = ref.read(sendProvider.notifier);

    _close() {
      // sendNotifier.clear();
      context.go("/");
    }

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: send?.sendStatus == "good" ? "Sent!" : "Sending...",
                closeAction: _close),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KeyValue(
                            k: "Send Status",
                            vw: statusProvider.when(
                                data: (data) => Text(
                                    data ?? "no status something went wrong?"),
                                loading: () => const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                error: (err, _) => Text(err.toString())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text:
                                send?.sendStatus == "good" ? "Nice" : "Give Up",
                            onPressed: _close,
                          )
                        ],
                      )
                    ]))));
  }
}
