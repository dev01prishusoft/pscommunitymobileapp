import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/constants/app_strings_preboot.dart';

//  ─────────────────────────────────────────────────────────────────
//  PRE-BOOTSTRAP SCREEN: GetX DI has not yet completed when this 
//  screen is shown. The localization system (.tr) is unavailable. 
//  All strings here are intentionally hardcoded in English. 
//  Do NOT add .tr calls — they will throw a LateInitializationError. 
//  ─────────────────────────────────────────────────────────────────
class PrebootColors {
  static const background = Color(0xFF0F172A);
  static const errorIcon = Color(0xFFEF4444);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF94A3B8);
  static const logBackground = Color(0xFF1E293B);
  static const logBorder = Colors.white10;
  static const logHeader = Color(0xFF3B82F6);
  static const logText = Color(0xFFF1F5F9);
  static const buttonBg = Color(0xFF3B82F6);
  static const buttonText = Colors.white;
}

class FatalErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const FatalErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: PrebootColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: PrebootColors.errorIcon,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  PrebootStrings.initError,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PrebootColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  PrebootStrings.initBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PrebootColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PrebootColors.logBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PrebootColors.logBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        PrebootStrings.errorLog,
                        style: TextStyle(
                          color: PrebootColors.logHeader,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$error',
                        style: const TextStyle(
                          color: PrebootColors.logText,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrebootColors.buttonBg,
                    foregroundColor: PrebootColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    PrebootStrings.closeApp,
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
