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
    // TODO just to compile not real yet
    final textController = TextEditingController();

    return SafeArea(
        child: Scaffold(
            appBar: PlnAppBar(
                title: "Open Channel", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Column(
                        children: [
                          BlandTextField(
                              controller: textController,
                              prompt: "Target Node",
                              iconData: Icons.memory),
                          SizedBox(
                            height: 12,
                          ),
                          BlandTextField(
                            controller: textController,
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
