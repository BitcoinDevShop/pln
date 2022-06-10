import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SafeArea(
        child: Scaffold(
            body: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text("Hello")))));
  }
}
