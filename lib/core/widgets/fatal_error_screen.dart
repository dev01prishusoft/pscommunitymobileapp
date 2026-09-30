import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/constants/app_strings_preboot.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
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

class FatalErrorScreen extends StatefulWidget {
  const FatalErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  final Object error;
  final StackTrace? stackTrace;
  final Future<void> Function()? onRetry;

  @override
  State<FatalErrorScreen> createState() => _FatalErrorScreenState();
}

class _FatalErrorScreenState extends State<FatalErrorScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying || widget.onRetry == null) return;
    setState(() {
      _isRetrying = true;
    });

    try {
      await widget.onRetry!();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: PrebootColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: PrebootColors.errorIcon,
                              size: 80,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              PrebootStrings.initError,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 30,
                                color: PrebootColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              PrebootStrings.initBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: PrebootColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // In debug mode: show raw error logs. In release mode: hide raw error details.
                            if (kDebugMode) ...[
                              Container(
                                width: double.infinity,
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
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: PrebootColors.logHeader,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${widget.error}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: PrebootColors.logText,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: PrebootColors.logBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: PrebootColors.logBorder.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  PrebootStrings.releaseNotice,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: PrebootColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons: Primary Retry + Secondary Close (on Android)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.onRetry != null) ...[
                              ElevatedButton(
                                onPressed: _isRetrying ? null : _handleRetry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PrebootColors.buttonBg,
                                  foregroundColor: PrebootColors.buttonText,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isRetrying
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.refresh_rounded, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            PrebootStrings.retry,
                                            style: AppTextStyles.labelLarge
                                                .copyWith(letterSpacing: 0.5),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Close button: On Android, SystemNavigator.pop works.
                            // On iOS, Apple blocks programmatic exit, so we only show Close on Android.
                            if (Platform.isAndroid)
                              TextButton(
                                onPressed: () {
                                  SystemNavigator.pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: PrebootColors.textSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  PrebootStrings.closeApp,
                                  style: AppTextStyles.labelMedium
                                      .copyWith(letterSpacing: 0.5),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
