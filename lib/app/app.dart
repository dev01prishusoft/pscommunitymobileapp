import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';

class PsCommunityApp extends StatelessWidget {
  const PsCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Get.find<LocalizationService>();
    
    return Obx(() => GetMaterialApp(
      title: LK.appTitle.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      // Localization
      translations: AppTranslations(localization.keys),
      locale: localization.currentLocale.value,
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

      initialRoute: Get.find<AuthState>().isAuthenticated.value 
          ? AppRouter.postLoginSplash 
          : AppRouter.login,
      getPages: AppRouter.pages,
    ));
  }
}
