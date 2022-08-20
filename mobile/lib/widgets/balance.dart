import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class Balance extends StatelessWidget {
  final int amountSats;
  const Balance(this.amountSats, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat.decimalPattern('en-us');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Text(f.format(amountSats).replaceAll(',', '_'),
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w300)),
        const Text(" SATS",
            style: TextStyle(
                fontFamily: "Yantramanav",
                color: white,
                fontSize: 24,
                fontWeight: FontWeight.w300)),
      ],
    );
  }
}
