import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:pscommunitymobileapp/core/di/di.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Orientation Lock
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Bootstrap DI (hydrates tokens, locale, config)
    await DI.bootstrap();

    runApp(const PsCommunityApp());
  } catch (e, stack) {
    AppLogger.e('Fatal crash during bootstrap', e, stack);
    // You could show a fatal error screen here
  }
}
