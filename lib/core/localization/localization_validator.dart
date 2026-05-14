import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

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
      
      final Map<String, dynamic> enMap = enDecoded;
      final Map<String, dynamic> guMap = guDecoded;
      
      int errorCount = 0;
      
      for (final key in LK.allValues) {
        if (!enMap.containsKey(key)) {
          AppLogger.e('Localization Error: Key "$key" missing in en_US.json');
          errorCount++;
        }
        if (!guMap.containsKey(key)) {
          AppLogger.e('Localization Error: Key "$key" missing in gu_IN.json');
          errorCount++;
        }
      }
      
      for (final key in enMap.keys) {
        if (!LK.allValues.contains(key)) {
          AppLogger.w('Localization Warning: Orphan key "$key" in en_US.json (not in LK.allValues)');
        }
      }
      
      for (final key in guMap.keys) {
        if (!LK.allValues.contains(key)) {
          AppLogger.w('Localization Warning: Orphan key "$key" in gu_IN.json (not in LK.allValues)');
        }
      }
      
      if (errorCount == 0) {
        AppLogger.i('Localization Validation: Passed (0 missing keys)');
      } else {
        AppLogger.e('Localization Validation: Failed with $errorCount missing keys');
      }
    } catch (e) {
      AppLogger.e('Localization Validation: Failed to load translation files', e);
    }
  }
}
