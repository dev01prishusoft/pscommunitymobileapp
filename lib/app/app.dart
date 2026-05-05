import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class PsCommunityApp extends StatelessWidget {
  const PsCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Get.find<LocalizationService>();

    return GetMaterialApp(
      title: LK.appTitle.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      // Localization
      translations: AppTranslations(localization.keys),
      locale: Get.locale ?? const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      
      // Support for Material Widgets localization (DatePickers, etc.)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('gu', 'IN'),
      ],

      initialRoute: AppRouter.login,
      getPages: AppRouter.pages,
    );
  }
}
