import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  ResponsiveHelper._();

  static const double mobileMaxSize = 600;
  static const double tabletMaxSize = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxSize;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxSize &&
      MediaQuery.of(context).size.width < tabletMaxSize;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxSize;

  static DeviceType getDeviceType(BuildContext context) {
    if (isDesktop(context)) return DeviceType.desktop;
    if (isTablet(context)) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Returns a value based on the current device size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Calculates an optimal cross axis count for GridViews based on screen width
  static int calculateGridCrossAxisCount(BuildContext context, {double desiredItemWidth = 150}) {
    final width = MediaQuery.of(context).size.width;
    final count = (width / desiredItemWidth).floor();
    return count > 0 ? count : 1;
  }
}
