import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:pscommunitymobileapp/core/di/di.dart';
import 'package:pscommunitymobileapp/core/lifecycle/app_lifecycle_observer.dart';
import 'package:pscommunitymobileapp/core/localization/localization_validator.dart';
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
