import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

// OLD
const lightGray = Color(0xffFCFCFC);
const niceGray = Color(0xffF0F0F0);
const black = Color(0xff000000);
const white = Color(0xffFFFFFF);
const lime = Color(0xffBAFF29);

// NEW

const greenStart = Color(0xff38CDA3);
const greenEnd = Color(0xff1EA67F);

const blueStart = Color(0xff7294EE);
const blueEnd = Color(0xff3861CE);

const grayEnd = Color(0xffD9D9D9);

const darkblueEnd = Color(0xff0B215B);

const promptText = Color(0xff4E5B7E);

const blue = Color(0xff7294ee);
const red = Color(0xffe23a5e);
const green = Color(0xff38CDA3);

var minimalshadow = <BoxShadow>[
  BoxShadow(
      color: black.withOpacity(0.1),
      offset: const Offset(2.0, 2.0),
      blurRadius: 4.0,
      inset: false),
  BoxShadow(
      color: white.withOpacity(0.4),
      offset: const Offset(4.0, 4.0),
      blurRadius: 4.0,
      inset: true),
  BoxShadow(
      color: black.withOpacity(0.5),
      offset: const Offset(-4.0, -4.0),
      blurRadius: 6.0,
      inset: true),
];

var invertedMinimalshadow = <BoxShadow>[
  BoxShadow(
      color: black.withOpacity(0.1),
      offset: const Offset(2.0, 2.0),
      blurRadius: 4.0,
      inset: false),
  BoxShadow(
      color: black.withOpacity(0.4),
      offset: const Offset(4.0, 4.0),
      blurRadius: 4.0,
      inset: true),
  BoxShadow(
      color: white.withOpacity(0.5),
      offset: const Offset(-4.0, -4.0),
      blurRadius: 6.0,
      inset: true),
];

var testShadow = [
  const BoxShadow(
    offset: Offset(-2, -2),
    blurRadius: 4,
    color: Colors.white,
    inset: true,
  ),
  const BoxShadow(
    offset: Offset(2, 2),
    blurRadius: 4,
    color: Color(0xFFBEBEBE),
    inset: true,
  ),
];

const spacer12 = SizedBox(height: 12);
const spacer24 = SizedBox(height: 24);
