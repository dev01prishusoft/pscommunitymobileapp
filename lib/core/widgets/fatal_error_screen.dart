import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/constants/app_strings_preboot.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class PrebootColors {
  static const background = Color(0xFF0F172A);
  static const errorIcon = Color(0xFFEF4444);
  static const textPrimary = AppColors.white;
  static const textSecondary = Color(0xFF94A3B8);
  static const logBackground = Color(0xFF1E293B);
  static const logBorder = AppColors.grey;
  static const logHeader = Color(0xFF3B82F6);
  static const logText = Color(0xFFF1F5F9);
  static const buttonBg = Color(0xFF3B82F6);
  static const buttonText = AppColors.white;
}

/// Shown when bootstrap fails. Runs outside ScreenUtilInit/GetMaterialApp, so
/// it must only use plain TextStyles (no `.sp`, no `.tr`).
class FatalErrorScreen extends StatefulWidget {
  const FatalErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });
  final Object error;
  final StackTrace? stackTrace;

  /// Re-runs bootstrap. When null, the button closes the app (Android only;
  /// iOS does not allow programmatic exit).
  final Future<void> Function()? onRetry;

  @override
  State<FatalErrorScreen> createState() => _FatalErrorScreenState();
}

class _FatalErrorScreenState extends State<FatalErrorScreen> {
  bool _retrying = false;

  Future<void> _onPressed() async {
    final retry = widget.onRetry;
    if (retry == null) {
      await SystemNavigator.pop();
      return;
    }
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await retry();
    } finally {
      // If bootstrap failed again a new FatalErrorScreen replaced this one.
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: PrebootColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.error_outline_rounded,
                  color: PrebootColors.errorIcon,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  PrebootStrings.initError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: PrebootColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  PrebootStrings.initBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: PrebootColors.textSecondary,
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
                      Text(
                        PrebootStrings.errorLog,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: PrebootColors.logHeader,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        // Raw exception text is for developers only.
                        kDebugMode
                            ? '${widget.error}'
                            : PrebootStrings.unknownError,
                        style: const TextStyle(
                          fontSize: 12,
                          color: PrebootColors.logText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _retrying ? null : _onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrebootColors.buttonBg,
                    foregroundColor: PrebootColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _retrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PrebootColors.buttonText,
                          ),
                        )
                      : Text(
                          widget.onRetry != null
                              ? PrebootStrings.retry
                              : PrebootStrings.closeApp,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
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
