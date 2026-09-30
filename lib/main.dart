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
import 'package:pscommunitymobileapp/core/constants/di.dart';
import 'package:pscommunitymobileapp/core/constants/app_lifecycle_observer.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/localization_validator.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/widgets/fatal_error_screen.dart';
import 'package:pscommunitymobileapp/core/widgets/preboot_network_error_screen.dart';

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

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await DI.bootstrap();

    AppLifecycleObserver.instance.init();

    if (kDebugMode) {
      await LocalizationValidator.validate();
    }

    runApp(PsCommunityApp());
  } catch (e, stack) {
    final errStr = e.toString().toLowerCase();
    final isNetworkOrServer = e is Failure ||
        e is DioException ||
        e is SocketException ||
        e is TimeoutException ||
        errStr.contains('socketexception') ||
        errStr.contains('timeoutexception') ||
        errStr.contains('networkfailure') ||
        errStr.contains('serverfailure') ||
        errStr.contains('connection refused') ||
        errStr.contains('failed host lookup');

    if (isNetworkOrServer) {
      final isServerDown = errStr.contains('server') ||
          errStr.contains('50') ||
          errStr.contains('connection refused');
      runApp(
        PrebootNetworkErrorScreen(
          isServerDown: isServerDown,
          onRetry: () async {
            await _bootstrap();
          },
        ),
      );
    } else {
      runApp(FatalErrorScreen(error: e, stackTrace: stack));
    }
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
          return Obx(
            () => SafeArea(
              top: false,
              child: GetMaterialApp(
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
                  final mq = MediaQuery.of(context);
                  final clamped = mq.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.3,
                  );
                  return MediaQuery(
                    data: mq.copyWith(textScaler: clamped),
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
