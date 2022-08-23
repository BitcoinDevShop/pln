import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:mutiny/constants.dart';

class BackgroundButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool disabled;
  final Color accentColor;
  final Widget child;

  const BackgroundButton(
      {Key? key,
      this.onPressed,
      this.disabled = false,
      this.accentColor = grayEnd,
      required this.child})
      : super(key: key);

  @override
  State<BackgroundButton> createState() => _BackgroundButtonState();
}

class _BackgroundButtonState extends State<BackgroundButton> {
  bool _isPressed = false;

  void press() {
    setState(() {
      _isPressed = true;
    });
  }

  void unpress() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (details) => press(),
      onTapUp: (details) => unpress(),
      onTapCancel: () => unpress(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? widget.accentColor : null,
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        ),
        child: widget.child,
      ),
    );
  }
}
