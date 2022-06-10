import 'package:flutter/material.dart';

class KeyValue extends StatelessWidget {
  final String k;
  final String v;

  const KeyValue({Key? key, required this.k, required this.v})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(v),
      ],
    );
  }
}
