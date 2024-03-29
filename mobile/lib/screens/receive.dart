import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/constants.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/button.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mutiny/widgets/super_safe_area.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://abytesjourney.com/lightning-privacy/');

class Receive extends ConsumerWidget {
  const Receive({Key? key}) : super(key: key);

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SuperSafeArea(
        appBar: PlnAppBar(
            accentColor: red,
            title: "RECEIVE",
            closeAction: () => context.go("/")),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24.0),
              Expanded(
                  child: GestureDetector(
                onLongPress: _launchUrl,
                child: Image.asset("images/no-receive.png", fit: BoxFit.cover),
              )),
              const SizedBox(height: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlandButton(
                      text: "Okay...", onPressed: () => context.go("/")),
                ],
              )
            ]));
  }
}
