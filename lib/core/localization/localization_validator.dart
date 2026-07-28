import 'dart:convert';

import 'package:flutter/services.dart';

class LocalizationValidator {
  static Future<void> validate() async {
    try {
      final enString = await rootBundle.loadString('assets/locales/en_US.json');
      final guString = await rootBundle.loadString('assets/locales/gu_IN.json');

      final dynamic enDecoded = jsonDecode(enString);
      final dynamic guDecoded = jsonDecode(guString);

      if (enDecoded is! Map<String, dynamic>) {
        throw Exception('Invalid localization JSON structure in en_US.json');
      }
      if (guDecoded is! Map<String, dynamic>) {
        throw Exception('Invalid localization JSON structure in gu_IN.json');
      }
    } catch (_) {}
  }
}
