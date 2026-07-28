import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/models/language.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart'
    as pscommunitymobileapp_token_manager;

class LocalizationService {
  LocalizationService(this._storage);

  final SecureStorageService _storage;
  static final _localeKey = 'app_locale';
  final Rx<Locale> currentLocale = Locale('en', 'US').obs;

  final RxList<Language> languages = <Language>[].obs;
  bool _isFetchingLanguages = false;

  late Map<String, Map<String, String>> keys;

  Future<File> _getLocalFile(String localeKey) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cached_locales_$localeKey.json');
  }

  Future<void> bootstrap() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/locales/en_US.json'),
      rootBundle.loadString('assets/locales/gu_IN.json'),
    ]);

    keys = {
      'en_US': Map<String, String>.from(jsonDecode(results[0]) as Map),
      'gu_IN': Map<String, String>.from(jsonDecode(results[1]) as Map),
    };
    for (final localeKey in keys.keys) {
      try {
        final file = await _getLocalFile(localeKey);
        if (await file.exists()) {
          final content = await file.readAsString();
          final cachedKeys = Map<String, String>.from(
            jsonDecode(content) as Map,
          );
          keys[localeKey]!.addAll(cachedKeys);
        }
      } catch (_) {}
    }
    try {
      unawaited(fetchLanguagesAndAllResources());
    } catch (_) {}

    final savedLocale = await _storage.read(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        try {
          await Get.updateLocale(locale);
        } catch (_) {}
      }
    }
  }

  Future<void> restoreSavedLocale() async {
    final savedLocale = await _storage.read(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        try {
          await Get.updateLocale(locale);
        } catch (_) {}
      }
    } else {
      final defaultLocale = const Locale('en', 'US');
      currentLocale.value = defaultLocale;
      try {
        await Get.updateLocale(defaultLocale);
      } catch (_) {}
    }
  }

  Future<void> fetchLanguagesAndAllResources() async {
    try {
      await fetchLanguages();
      await Future.wait(languages.map((l) => fetchLanguageResources(l.code)));
    } catch (_) {}
  }

  Future<void> fetchLanguages() async {
    if (_isFetchingLanguages || languages.isNotEmpty) return;

    final tokenManager =
        Get.find<pscommunitymobileapp_token_manager.TokenManager>();
    if (tokenManager.accessToken == null || tokenManager.accessToken!.isEmpty) {
      return;
    }

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

        if (languages.isNotEmpty) {
          final currentCode = currentLocale.value.languageCode;
          final isSupported = languages.any(
            (lang) => lang.code.toLowerCase() == currentCode.toLowerCase(),
          );

          if (!isSupported) {
            final fallback = languages.first;
            await changeLocale(fallback.code.toLowerCase(), '');
          }
        }
      }
    } catch (_) {
    } finally {
      _isFetchingLanguages = false;
    }
  }

  Future<void> fetchLanguageResources(String langCode) async {
    try {
      final tokenManager =
          Get.find<pscommunitymobileapp_token_manager.TokenManager>();
      if (tokenManager.accessToken == null ||
          tokenManager.accessToken!.isEmpty) {
        return;
      }

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        ApiEndpoints.languageResources(langCode),
      );
      final json = response.data as Map<String, dynamic>?;
      if (json != null && json['succeeded'] == true) {
        final data = json['data'] as Map<String, dynamic>?;
        if (data != null) {
          final remoteKeys = data.map(
            (key, value) => MapEntry(key, value.toString()),
          );
          


          final localeKey = keys.keys.firstWhere(
            (k) => k.startsWith(langCode),
            orElse: () => '${langCode}_US',
          );

          if (!keys.containsKey(localeKey)) {
            keys[localeKey] = {};
          }
          keys[localeKey]!.addAll(remoteKeys);
          try {
            final file = await _getLocalFile(localeKey);
            await file.writeAsString(jsonEncode(keys[localeKey]));
          } catch (_) {}

          Get.appendTranslations({localeKey: remoteKeys});
        }
      }
    } catch (_) {}
  }

  Future<void> changeLocale(String langCode, String countryCode) async {
    final locale = Locale(langCode, countryCode);
    currentLocale.value = locale;
    await Get.updateLocale(locale);
    await _storage.write(_localeKey, '${langCode}_$countryCode');
    try {
      unawaited(fetchLanguageResources(langCode));
    } catch (_) {}
  }

  void clearLanguages() {
    languages.clear();
  }

  Future<bool> hasSavedLocale() async {
    final saved = await _storage.read(_localeKey);
    return saved != null && saved.isNotEmpty;
  }

  Future<void> resetToDefaultLocale() async {
    await _storage.delete(_localeKey);
    final locale = const Locale('en', 'US');
    currentLocale.value = locale;
    await Get.updateLocale(locale);
  }
}
