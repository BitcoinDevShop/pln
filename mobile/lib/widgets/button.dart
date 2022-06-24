import 'package:flutter/material.dart';

import '../constants.dart';

class BlandButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool disabled;
  const BlandButton(
      {Key? key, required this.text, this.onPressed, this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          textStyle: Theme.of(context).textTheme.headline3,

          elevation: 5,
          onPrimary: black,
          // textStyle: const TextStyle(color: black),
          primary: niceGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed:
            disabled ? null : onPressed ?? () => debugPrint('unimplemented'),
        child: Text(text));
  }
}
