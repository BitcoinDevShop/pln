import 'package:flutter/material.dart';
import 'package:pln/constants.dart';

class SuperSafeArea extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget appBar;
  const SuperSafeArea({Key? key, required this.child, required this.appBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            black,
            darkblueEnd,
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
            appBar: appBar,
            backgroundColor: Colors.transparent,
            body: Padding(padding: const EdgeInsets.all(24.0), child: child)),
      ),
    );
  }
}
