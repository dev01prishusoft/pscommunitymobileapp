import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class AppValidators {
  static final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

  static String? required(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? 'This field is required';
    }
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LK.pleaseEnterMobile.tr;
    }
    if (!_mobileRegex.hasMatch(value.trim())) {
      return LK.pleaseEnterValidMobile.tr;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return LK.pleaseEnterPassword.tr;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$&*~)';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length < 4) {
      return 'Please enter a valid OTP';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!Uri.parse(value.trim()).isAbsolute) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}
