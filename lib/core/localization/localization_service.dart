import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/models/language.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class LocalizationService {
  LocalizationService(this._storage);

  final SecureStorageService _storage;
  static const _localeKey = 'app_locale';
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;
  
  final RxList<Language> languages = <Language>[].obs;
  bool _isFetchingLanguages = false;

  late Map<String, Map<String, String>> keys;

  Future<void> bootstrap() async {
    // Load translations in parallel
    final results = await Future.wait([
      rootBundle.loadString('assets/locales/en_US.json'),
      rootBundle.loadString('assets/locales/gu_IN.json'),
    ]);

    keys = {
      'en_US': Map<String, String>.from(jsonDecode(results[0]) as Map),
      'gj_IN': Map<String, String>.from(jsonDecode(results[1]) as Map),
    };

    // Restore saved locale
    final savedLocale = await _storage.read(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        await Get.updateLocale(locale);
      }
    }
  }

  Future<void> fetchLanguages() async {
    if (_isFetchingLanguages || languages.isNotEmpty) return;
    _isFetchingLanguages = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.languageDropdown);
      final json = response.data as Map<String, dynamic>?;
      if (json != null && json['succeeded'] == true) {
        final data = json['data'] as List? ?? [];
        languages.assignAll(
          data
              .whereType<Map<String, dynamic>>()
              .map(Language.fromJson)
              .toList(),
        );
      }
    } catch (_) {
      // Non-fatal — fallback language codes are shown in the dropdown
    } finally {
      _isFetchingLanguages = false;
    }
  }

  Future<void> changeLocale(String langCode, String countryCode) async {
    final locale = Locale(langCode, countryCode);
    currentLocale.value = locale;
    await Get.updateLocale(locale);
    await _storage.write(_localeKey, '${langCode}_$countryCode');
  }
}
