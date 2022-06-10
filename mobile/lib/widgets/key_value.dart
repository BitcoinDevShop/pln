import 'package:flutter/material.dart';

class KeyValue extends StatelessWidget {
  final String k;
  final String? v;
  final Widget? vw;

  const KeyValue({Key? key, required this.k, this.v, this.vw})
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
        const SizedBox(height: 4),
        vw != null ? vw! : Text(v!),
      ],
    );
  }
}
