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
        Text(f.format(amountSats),
            style: Theme.of(context).textTheme.headline2),
        const Text(" sats",
            style: TextStyle(
                fontFamily: "Inter",
                color: black,
                fontSize: 24,
                fontWeight: FontWeight.w400)),
      ],
    );
  }
}
