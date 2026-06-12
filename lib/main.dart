import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/di/di.dart';
import 'package:pscommunitymobileapp/core/localization/localization_validator.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/widgets/fatal_error_screen.dart';
import 'package:pscommunitymobileapp/core/lifecycle/app_lifecycle_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    // Setting fatal to true will force the app to crash natively on Android.
    // Async errors like Image 404s should NOT crash the app.
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    debugPrint('UNCAUGHT ASYNC ERROR: $error\n$stack');
    AppLogger.e('Uncaught async error', error, stack);
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
      debugPrint('FLUTTER FRAMEWORK ERROR: ${details.exception}\n${details.stack}');
      AppLogger.e('Flutter framework error', details.exception, details.stack);
    };

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await DI.bootstrap();
    
    AppLifecycleObserver.instance.init();

    if (kDebugMode) {
      await LocalizationValidator.validate();
    }

    runApp(PsCommunityApp());
  } catch (e, stack) {
    debugPrint('FATAL CRASH DURING BOOTSTRAP: $e\n$stack');
    AppLogger.e('Fatal crash during bootstrap', e, stack);
    runApp(FatalErrorScreen(error: e, stackTrace: stack));
  }
}
