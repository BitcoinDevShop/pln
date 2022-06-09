import 'package:flutter/material.dart';

import '../constants.dart';

class BlandButton extends StatelessWidget {
  // final VoidCallback? onPressed;
  final VoidCallback? onPressed;
  final String text;
  const BlandButton({Key? key, required this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          onPrimary: black,
          // textStyle: const TextStyle(color: black),
          primary: niceGray,
          // TODO how do you just do a rect?
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: onPressed ?? () => debugPrint('unimplemented'),
        child: Text(text));
  }
}
