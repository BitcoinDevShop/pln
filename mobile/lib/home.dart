import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/balance.dart';
import 'package:pln/widgets/button.dart';

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      const Balance(420),
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
