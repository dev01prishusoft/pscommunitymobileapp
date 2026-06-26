import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class AppValidators {
  static final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

  static String? required(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? LK.fieldRequired.tr;
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

  static String? optionalMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_mobileRegex.hasMatch(value.trim())) {
      return LK.pleaseEnterValidMobile.tr;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LK.pleaseEnterEmail.tr;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return LK.pleaseEnterValidEmail.tr;
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return LK.pleaseEnterValidEmail.tr;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return LK.pleaseEnterPassword.tr;
    }
    return null;
  }

  static String? complexPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LK.pleaseEnterPassword.tr;
    }
    if (value.length < 8) {
      return LK.passwordMinLength.tr;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return LK.passwordLowercase.tr;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return LK.passwordUppercase.tr;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return LK.passwordNumber.tr;
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return LK.passwordSpecialChar.tr;
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LK.pleaseEnterOTP.tr;
    }
    if (value.length < 4) {
      return LK.pleaseEnterValidOTP.tr;
    }
    return null;
  }

  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*(\?[\/\w\.~%&=#+?\-]*)?(\#[\/\w\.~%&=#+?\-]*)?\/?$',
    caseSensitive: false,
  );

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_urlRegex.hasMatch(value.trim())) {
      return LK.pleaseEnterValidURL.tr;
    }
    return null;
  }
}
