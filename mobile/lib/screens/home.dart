import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/constants.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/balance.dart';
import 'package:pln/widgets/button.dart';
import 'package:pln/widgets/super_safe_area.dart';

final balanceStreamProvider = StreamProvider.autoDispose<int?>((ref) {
  Stream<int?> getStatus() async* {
    while (true) {
      try {
        final plnClient = ref.read(plnClientProvider);
        if (plnClient == null) {
          final plnClientNotifier = ref.read(plnClientProvider.notifier);
          await plnClientNotifier.restartClient();
          final plnClient = ref.read(plnClientProvider);
          if (plnClient == null) {
            throw ("no client");
          }
          await Future.delayed(const Duration(seconds: 5));
          final response = await plnClient.getBalance(GetBalanceRequest());
          yield response.amtSatoshis.toInt();
        } else {
          await Future.delayed(const Duration(seconds: 1));
          final response = await plnClient.getBalance(GetBalanceRequest());
          yield response.amtSatoshis.toInt();
        }
      } catch (e) {
        debugPrint("error: ${e.toString()}");
        yield null;
        // yield null;

      }
    }
  }

  return getStatus();
});

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<int?> state = ref.watch(balanceStreamProvider);

    _refresh() async {
      ref.refresh(balanceStreamProvider);
    }

    return SuperSafeArea(
        appBar: const PlnAppBar(
          accentColor: blue,
          title: "Mutiny",
          home: true,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer12,
              state.when(
                  data: (balance) => GestureDetector(
                      onTap: _refresh,
                      child: balance != null
                          ? Balance(balance)
                          : const Text("no connection")),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => Text(err.toString())),
              state.when(
                data: (balance) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlandButton(
                        disabled: balance == null,
                        text: "SEND",
                        green: true,
                        onPressed: () => context.go("/send")),
                    spacer12,
                    BlandButton(
                        text: "DEPOSIT",
                        blue: true,
                        onPressed: () => context.go("/channel")),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlandButton(
                      disabled: true,
                      text: "SEND",
                      green: true,
                      onPressed: () => {},
                    ),
                    spacer12,
                    BlandButton(
                      disabled: true,
                      text: "DEPOSIT",
                      blue: true,
                      onPressed: () => {},
                    )
                  ],
                ),
                error: (err, _) => const SizedBox(height: 0),
              )
            ]));
  }
}
