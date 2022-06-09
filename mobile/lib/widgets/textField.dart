import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:pln/constants.dart';

// import 'constants.dart';

class BlandTextField extends StatelessWidget {
  final String prompt;
  final IconData? iconData;
  const BlandTextField({
    Key? key,
    required this.prompt,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lightGray,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0.0, 2.0),
              blurRadius: 3.0,
              inset: true),
          BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(0.0, 2.0),
              blurRadius: 3.0,
              inset: true)
        ],
      ),
      child: TextField(
        expands: false,
        // style: TextStyle(fontSize: 20.0, color: Colors.black45),
        decoration: InputDecoration(
          // contentPadding: EdgeInsets.all(12.0),
          prefixIcon: iconData != null
              ? Icon(
                  iconData,
                  color: Colors.black,
                )
              : null,
          hintText: prompt,
          // hintStyle: TextStyle(color: Colors.black54),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: black),
            borderRadius: BorderRadius.circular(0.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: lightGray),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
      ),
    );
  }
}
