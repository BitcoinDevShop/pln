import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/generated/pln.pbgrpc.dart';
import 'package:pln/grpc.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/balance.dart';
import 'package:pln/widgets/button.dart';

final balanceFutureProvider = FutureProvider<int>(
  (ref) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final response =
        await plnClient.getBalance(GetBalanceRequest()); // our future
    return response.amtSatoshis.toInt(); //returns a list of all the hospitals
  },
);

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<int> state = ref.watch(balanceFutureProvider);

    _refresh() async {
      ref.refresh(balanceFutureProvider);
    }

    return SafeArea(
        child: Scaffold(
            appBar: const PlnAppBar(
              title: "pLN",
              home: true,
            ),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      state.when(
                          data: (balance) => GestureDetector(
                              onTap: _refresh, child: Balance(balance)),
                          loading: () => const Text("..."),
                          error: (err, _) => Text(err.toString())),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Send",
                              onPressed: () => context.go("/send")),
                          const SizedBox(height: 12),
                          BlandButton(
                              text: "Receive",
                              onPressed: () => context.go("/receive")),
                          const SizedBox(height: 12),
                          BlandButton(
                            text: "Open Channel",
                            onPressed: () => context.go("/channel"),
                          )
                        ],
                      )
                    ]))));
  }
}
