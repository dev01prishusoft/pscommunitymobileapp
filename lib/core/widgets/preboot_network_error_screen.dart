import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/app_translations.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class PrebootNetworkErrorScreen extends StatefulWidget {
  const PrebootNetworkErrorScreen({
    super.key,
    required this.onRetry,
    this.isServerDown = true,
    this.errorMessage,
  });

  final Future<void> Function() onRetry;
  final bool isServerDown;
  final String? errorMessage;

  @override
  State<PrebootNetworkErrorScreen> createState() =>
      _PrebootNetworkErrorScreenState();
}

class _PrebootNetworkErrorScreenState extends State<PrebootNetworkErrorScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() {
      _isRetrying = true;
    });

    try {
      await widget.onRetry();
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
    final localization = Get.isRegistered<LocalizationService>()
        ? Get.find<LocalizationService>()
        : null;

    final title = widget.isServerDown
        ? LK.serverDownTitle.tr
        : LK.noInternetTitle.tr;

    final subtitle = widget.isServerDown
        ? LK.serverDownDesc.tr
        : LK.noInternetDesc.tr;

    final badge = widget.isServerDown
        ? LK.statusServerMaintenance.tr
        : LK.statusOffline.tr;

    final icon = widget.isServerDown
        ? Icons.cloud_off_rounded
        : Icons.wifi_off_rounded;

    final primaryColor = widget.isServerDown
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations:
          localization != null ? AppTranslations(localization.keys) : null,
      locale: localization?.currentLocale.value ?? const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isRetrying ? null : _handleRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                    LK.tryAgain.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: Text(
                          LK.exitApp.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
