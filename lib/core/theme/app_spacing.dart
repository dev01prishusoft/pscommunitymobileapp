import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double section = 48.0;
  static double get xsW => xs.w;
  static double get sW => s.w;
  static double get mW => m.w;
  static double get lW => l.w;
  static double get xlW => xl.w;
  static double get xxlW => xxl.w;
  static double get xxxlW => xxxl.w;

  static double get xsH => xs.h;
  static double get sH => s.h;
  static double get mH => m.h;
  static double get lH => l.h;
  static double get xlH => xl.h;
  static double get xxlH => xxl.h;
  static double get xxxlH => xxxl.h;
  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vS = SizedBox(height: s);
  static const SizedBox vM = SizedBox(height: m);
  static const SizedBox vL = SizedBox(height: l);
  static const SizedBox vXl = SizedBox(height: xl);
  static const SizedBox vXxl = SizedBox(height: xxl);
  static const SizedBox vXxxl = SizedBox(height: xxxl);
  static const SizedBox vSection = SizedBox(height: section);
  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hS = SizedBox(width: s);
  static const SizedBox hM = SizedBox(width: m);
  static const SizedBox hL = SizedBox(width: l);
  static const SizedBox hXl = SizedBox(width: xl);
  static const SizedBox hXxl = SizedBox(width: xxl);
  static const SizedBox hXxxl = SizedBox(width: xxxl);
  static const EdgeInsets pXs = EdgeInsets.all(xs);
  static const EdgeInsets pS = EdgeInsets.all(s);
  static const EdgeInsets pM = EdgeInsets.all(m);
  static const EdgeInsets pL = EdgeInsets.all(l);
  static const EdgeInsets pXl = EdgeInsets.all(xl);
  
  static const EdgeInsets pHXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets pHL = EdgeInsets.symmetric(horizontal: l);
  
  static const EdgeInsets pScreen = EdgeInsets.symmetric(horizontal: l, vertical: l);
  static const EdgeInsets pScreenTop = EdgeInsets.only(left: l, right: l, top: l);
  static const EdgeInsets pScreenBottom = EdgeInsets.only(left: l, right: l, bottom: l);
}
