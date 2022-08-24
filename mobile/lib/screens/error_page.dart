import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/constants.dart';
import 'package:mutiny/pln_appbar.dart';
import 'package:mutiny/widgets/key_value.dart';
import 'package:mutiny/widgets/super_safe_area.dart';

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
      child: SingleChildScrollView(
        child: Center(
            child: KeyValue(
                k: "WHY",
                v: errorReason != null
                    ? errorReason.toString()
                    : errorMessage != null
                        ? errorMessage!
                        : "Unknown Error")),
      ),
    );
  }
}
