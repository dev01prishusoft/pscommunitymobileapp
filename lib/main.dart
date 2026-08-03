import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/auth/session_manager.dart';
import 'package:pscommunitymobileapp/core/constants/di.dart';
import 'package:pscommunitymobileapp/core/constants/app_lifecycle_observer.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/localization_validator.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/fatal_error_screen.dart';

import 'firebase_options.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  });
}

Future<void> _bootstrap() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await DI.bootstrap();

    AppLifecycleObserver.instance.init();

    if (kDebugMode) {
      await LocalizationValidator.validate();
    }

    runApp(PsCommunityApp());
  } catch (e, stack) {
    runApp(FatalErrorScreen(error: e, stackTrace: stack));
  }
}

class PsCommunityApp extends StatelessWidget {
  const PsCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Get.find<LocalizationService>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ScreenUtilInit(
        designSize: Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => Get.find<SessionManager>().userInteracted(),
            onPointerMove: (_) => Get.find<SessionManager>().userInteracted(),
            onPointerUp: (_) => Get.find<SessionManager>().userInteracted(),
            child: Obx(
              () => GetMaterialApp(
                title: LK.appTitle.tr,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                translations: AppTranslations(localization.keys),
                locale: localization.currentLocale.value,
                fallbackLocale: Locale('en', 'US'),
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
                navigatorObservers: [AppRouter.routeObserver],
                getPages: AppRouter.pages,
                builder: (context, child) {
                  return Localizations.override(
                    context: context,
                    locale: const Locale('en', 'US'),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
