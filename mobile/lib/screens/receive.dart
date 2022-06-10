import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://abytesjourney.com/lightning-privacy/');

class Receive extends ConsumerWidget {
  const Receive({Key? key}) : super(key: key);

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: Scaffold(
            appBar:
                PlnAppBar(title: "Receive", closeAction: () => context.go("/")),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Expanded(
                          child: GestureDetector(
                        onLongPress: _launchUrl,
                        child: Image.asset("images/no-receive.png",
                            fit: BoxFit.cover),
                      )),
                      const SizedBox(height: 48),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlandButton(
                              text: "Okay...",
                              onPressed: () => context.go("/")),
                        ],
                      )
                    ]))));
  }
}
