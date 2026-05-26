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

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    debugPrint('UNCAUGHT ASYNC ERROR: $error\n$stack');
    AppLogger.e('Uncaught async error', error, stack);
  });
}

Future<void> _bootstrap() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
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
