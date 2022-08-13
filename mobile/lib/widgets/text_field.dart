import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:pln/constants.dart';

class BlandTextField extends StatelessWidget {
  final String prompt;
  final IconData? iconData;
  final TextEditingController controller;
  final Color accentColor;

  const BlandTextField({
    Key? key,
    required this.prompt,
    this.iconData,
    required this.controller,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lightGray,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(4.0, 4.0),
              blurRadius: 3.0,
              inset: true),
        ],
      ),
      child: TextField(
        controller: controller,
        expands: false,
        style: const TextStyle(fontSize: 20.0, color: black),
        cursorColor: black,
        decoration: InputDecoration(
          // contentPadding: EdgeInsets.all(12.0),
          prefixIcon: iconData != null
              ? Icon(
                  iconData,
                  color: Colors.black,
                )
              : null,
          hintText: prompt,
          hintStyle:
              const TextStyle(color: promptText, fontWeight: FontWeight.w300),
          // hintStyle: TextStyle(color: Colors.black54),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
      ),
    );
  }
}
