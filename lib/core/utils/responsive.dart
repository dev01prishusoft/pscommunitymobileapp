import 'package:flutter/material.dart';

class R {
  static double w(double value, BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return value * (screenWidth / 390);
  }

  static double h(double value, BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return value * (screenHeight / 844);
  }

  static double sp(double value, BuildContext context) {
    return w(value, context);
  }
}
