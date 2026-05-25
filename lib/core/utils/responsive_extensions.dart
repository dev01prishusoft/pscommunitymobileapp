import 'package:flutter/material.dart';
import 'responsive_helper.dart';

extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Returns value based on screen size
  T adaptiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    return ResponsiveHelper.value<T>(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Calculates dynamic optimal max width for forms to avoid them looking stretched on tablets
  double get optimalFormWidth {
    if (isTablet || isDesktop) return 600.0;
    return screenWidth;
  }
}
