import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:pln/widgets/textField.dart';

class Channel extends ConsumerWidget {
  const Channel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "pLN - Open Channel",
                closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Column(
                        children: const [
                          BlandTextField(
                              prompt: "Target Node", iconData: Icons.memory),
                          SizedBox(
                            height: 12,
                          ),
                          BlandTextField(
                            prompt: "How Much",
                            iconData: Icons.expand,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                            text: "Continue",
                            onPressed: () => context.go("/channel/fund"),
                          )
                        ],
                      )
                    ]))));
  }
}
