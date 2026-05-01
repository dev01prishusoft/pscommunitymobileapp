import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load translations from JSON assets
  final enUSString = await rootBundle.loadString('assets/locales/en_US.json');
  final guINString = await rootBundle.loadString('assets/locales/gu_IN.json');

  final enUSMap = Map<String, String>.from(jsonDecode(enUSString));
  final guINMap = Map<String, String>.from(jsonDecode(guINString));

  final translations = AppTranslations({
    'en_US': enUSMap,
    'gu_IN': guINMap,
  });

  runApp(PsCommunityApp(translations: translations));
}
