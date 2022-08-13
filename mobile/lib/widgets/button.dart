import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:pln/constants.dart';

class BlandButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool disabled;
  final bool blue;
  final bool green;
  const BlandButton(
      {Key? key,
      required this.text,
      this.onPressed,
      this.disabled = false,
      this.blue = false,
      this.green = false})
      : super(key: key);

  @override
  State<BlandButton> createState() => _BlandButtonState();
}

class _BlandButtonState extends State<BlandButton> {
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
    const greenGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        greenStart,
        greenEnd,
      ],
    );

    const blueGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        blueStart,
        blueEnd,
      ],
    );

    const grayGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        white,
        grayEnd,
      ],
    );

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (details) => press(),
      onTapUp: (details) => unpress(),
      onTapCancel: () => unpress(),
      child: Row(
        // TODO there's a simpler way to do this yeah?
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: widget.disabled ? 0.5 : 1.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: _isPressed ? invertedMinimalshadow : minimalshadow,
                gradient: widget.green
                    ? greenGradient
                    : widget.blue
                        ? blueGradient
                        : grayGradient,
                // gradient: LinearGradient(
                //   begin: const Alignment(0.0, 0.0),
                //   end: const Alignment(-0.21, 0.978),
                //   colors: [Color(rgb(5600),const Color(0x00005014),const Color(0x00003fac),Color(rgb(3000),const Color(0x000040d8),const Color(0x0000007f) 101.77%)00)],
                //   steps: const [-0.0054]
                // ),
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Text(widget.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: widget.blue || widget.green ? white : black,
                    shadows: _isPressed
                        ? null
                        : <Shadow>[
                            Shadow(
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: black.withOpacity(0.15),
                            ),
                          ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
