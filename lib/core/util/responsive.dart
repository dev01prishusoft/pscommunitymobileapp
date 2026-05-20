import 'package:flutter/material.dart';

// Since flutter_screenutil might not be installed yet or configured, 
// we'll use a MediaQuery-based responsive helper for now, which doesn't require setup.
// If you want ScreenUtil, we can switch to it.

class R {
  static double w(double value, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Assuming design width is 390 (standard phone)
    return value * (screenWidth / 390);
  }

  static double h(double value, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // Assuming design height is 844
    return value * (screenHeight / 844);
  }

  static double sp(double value, BuildContext context) {
    // Basic scaling for font size based on width
    return w(value, context);
  }
}
