import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/models/language.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

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
    
    // Load from local file cache if available
    for (final localeKey in keys.keys) {
      try {
        final file = await _getLocalFile(localeKey);
        if (await file.exists()) {
          final content = await file.readAsString();
          final cachedKeys = Map<String, String>.from(jsonDecode(content) as Map);
          keys[localeKey]!.addAll(cachedKeys);
        }
      } catch (e) {
        AppLogger.e('Failed to load cached locale file for $localeKey', e);
      }
    }
    
    // Fetch remote translations silently in background
    unawaited(fetchLanguagesAndAllResources());
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

  Future<void> restoreSavedLocale() async {
    final savedLocale = await _storage.read(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        await Get.updateLocale(locale);
      }
    } else {
      final defaultLocale = const Locale('en', 'US');
      currentLocale.value = defaultLocale;
      await Get.updateLocale(defaultLocale);
    }
  }

  Future<void> fetchLanguagesAndAllResources() async {
    try {
      await fetchLanguages();
      await Future.wait(languages.map((l) => fetchLanguageResources(l.code)));
    } catch (e, stack) {
      AppLogger.e('Failed to fetch languages and all resources', e, stack);
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

        if (languages.isNotEmpty) {
          final currentCode = currentLocale.value.languageCode;
          final isSupported = languages.any((lang) => lang.code.toLowerCase() == currentCode.toLowerCase());
          
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
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.languageResources(langCode));
      final json = response.data as Map<String, dynamic>?;
      if (json != null && json['succeeded'] == true) {
        final data = json['data'] as Map<String, dynamic>?;
        if (data != null) {
          final remoteKeys = data.map((key, value) => MapEntry(key, value.toString()));
          final localeKey = keys.keys.firstWhere(
            (k) => k.startsWith(langCode), 
            orElse: () => '${langCode}_US'
          );
          
          if (!keys.containsKey(localeKey)) {
             keys[localeKey] = {};
          }
          keys[localeKey]!.addAll(remoteKeys);
          
          // Save to local cache
          try {
            final file = await _getLocalFile(localeKey);
            await file.writeAsString(jsonEncode(keys[localeKey]));
          } catch (e) {
            AppLogger.e('Failed to save cached locale file for $localeKey', e);
          }
          
          Get.appendTranslations({
            localeKey: remoteKeys
          });
          
          AppLogger.d('Appended and cached ${remoteKeys.length} translations for $langCode');
        }
      }
    } catch (e, stack) {
      AppLogger.e('Failed to fetch remote language resources for $langCode', e, stack);
    }
  }

  Future<void> changeLocale(String langCode, String countryCode) async {
    final locale = Locale(langCode, countryCode);
    currentLocale.value = locale;
    await Get.updateLocale(locale);
    await _storage.write(_localeKey, '${langCode}_$countryCode');
    unawaited(fetchLanguageResources(langCode));
  }

  void clearLanguages() {
    languages.clear();
  }
}

