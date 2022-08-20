import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pln/constants.dart';
import 'package:pln/pln_appbar.dart';
import 'package:pln/widgets/super_safe_area.dart';

class ErrorPage extends StatelessWidget {
  final Exception? errorReason;
  final String? errorMessage;
  const ErrorPage({Key? key, this.errorReason, this.errorMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuperSafeArea(
      appBar: PlnAppBar(
        accentColor: white,
        title: "ERROR",
        closeAction: () => context.go("/"),
      ),
      child: Center(
          child: errorReason != null
              ? Text(errorReason.toString())
              : errorMessage != null
                  ? Text(errorMessage!)
                  : const Text("Unknown Error")),
    );
  }
}
