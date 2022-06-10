import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/data/channel.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:qr_flutter/qr_flutter.dart';

// final streamProvider = StreamProvider.autoDispose<String>((ref) async* {
//   // var status = [];
//   final channel = ref.read(channelProvider);
//   Stream<String>.periodic(
//     const Duration(milliseconds: 1000),
//     (count) {
//       return plnClient
//           .getChannel(GetChannelRequest(id: channel?.id))
//           .then((data) => await data.status); // our future
//     },
//   ).asyncMap((event) async {
//     // final res = event;
//     return event;
//   }).takeWhile((element) => false);
// });

// final periodic =
//     ChangeNotifierProvider.autoDispose.family((ref, Duration period) {
//   final notifier = ValueNotifier(-1);
//   final subscription =
//       Stream.periodic(period, id).listen((event) => notifier.value = event);
//   ref.onDispose(subscription.cancel);
//   return notifier;
// });

// const kPollingDuration = Duration(seconds: 10);

// class ChannelStatusManager extends StateNotifier<String> {
//   ChannelStatusManager(this.status) : super("") {
//     startPollingDevices();
//   }

//   @protected
//   final String status;

//   Timer? _timer;

//   Future<void> loadDevices() async {
//     state = await adb.devices();
//   }

//   void startPollingDevices() {
//     _timer?.cancel();
//     _timer = Timer.periodic(kPollingDuration, (_) async {
//       if (!adb.isProcessing) await loadDevices();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }

class ChannelStatus extends ConsumerWidget {
  const ChannelStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.read(channelProvider);
    final channelNotifier = ref.read(channelProvider.notifier);
    final channelWatch = ref.watch(channelProvider);

    // final asyncValue = ref.watch(streamProvider);

    // final channelFutureProvider = FutureProvider<String>(
    //   (ref) async {
    //     await Future.delayed(const Duration(milliseconds: 200));
    //     final response = await plnClient
    //         .getChannel(GetChannelRequest(id: channel?.id)); // our future
    //     return response.status; //returns a list of all the hospitals
    //   },
    // );

    // _refresh() async {
    //   ref.refresh(channelFutureProvider);
    // }

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
