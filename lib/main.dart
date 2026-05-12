import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:pscommunitymobileapp/core/di/di.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/widgets/fatal_error_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Orientation Lock
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Load Environment Variables
    await dotenv.load(fileName: ".env");

    // Bootstrap DI (hydrates tokens, locale, config)
    await DI.bootstrap();

    runApp(const PsCommunityApp());
  } catch (e, stack) {
    AppLogger.e('Fatal crash during bootstrap', e, stack);
    runApp(FatalErrorScreen(error: e, stackTrace: stack));
  }
}
