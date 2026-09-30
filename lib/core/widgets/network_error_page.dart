import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/services/global_network_error_service.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class NetworkErrorPage extends StatefulWidget {
  const NetworkErrorPage({super.key});

  @override
  State<NetworkErrorPage> createState() => _NetworkErrorPageState();
}

class _NetworkErrorPageState extends State<NetworkErrorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = Get.isRegistered<GlobalNetworkErrorService>()
        ? GlobalNetworkErrorService.to
        : null;

    final NetworkErrorArgs? args =
        Get.arguments is NetworkErrorArgs ? Get.arguments as NetworkErrorArgs : null;

    final canGoBack = args?.canGoBack ?? (Navigator.of(context).canPop());

    return PopScope(
      canPop: canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && service != null) {
          service.isErrorScreenOpen.value = false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Bar: Back button (if available) & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (canGoBack)
                              InkWell(
                                onTap: () {
                                  service?.isErrorScreenOpen.value = false;
                                  Navigator.of(context).maybePop();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Obx(() {
                              final type = service?.currentErrorType.value ??
                                  args?.type ??
                                  NetworkErrorType.serverDown;
                              return _buildStatusBadge(type);
                            }),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Center Section: Hero Animation, Title, Description, Diagnostic Card
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              final type = service?.currentErrorType.value ??
                                  args?.type ??
                                  NetworkErrorType.serverDown;
                              return ScaleTransition(
                                scale: _pulseAnimation,
                                child: _buildHeroIllustration(type),
                              );
                            }),
                            SizedBox(height: 32.h),

                            // Title & Description
                            Obx(() {
                              final type = service?.currentErrorType.value ??
                                  args?.type ??
                                  NetworkErrorType.serverDown;
                              return Column(
                                children: [
                                  Text(
                                    _getTitle(type, args?.customTitle),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    _getDescription(type, args?.customMessage),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xFF64748B),
                                      height: 1.5,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              );
                            }),

                            SizedBox(height: 28.h),

                            // Diagnostics Card
                            _buildDiagnosticsCard(service),
                          ],
                        ),

                        SizedBox(height: 32.h),

                        // Bottom Actions: Try Again & Go Back Buttons
                        Column(
                          children: [
                            Obx(() {
                              final isChecking =
                                  service?.isCheckingConnection.value ?? false;
                              return Container(
                                width: double.infinity,
                                height: 52.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: isChecking
                                        ? [Colors.grey.shade400, Colors.grey.shade500]
                                        : [AppColors.primary, AppColors.secondary],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    if (!isChecking)
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isChecking
                                        ? null
                                        : () {
                                            service?.testAndRecover();
                                          },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: isChecking
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                  height: 20.w,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Text(
                                                  LK.checkingConnection.tr,
                                                  style: AppTextStyles.labelLarge
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  LK.tryAgain.tr,
                                                  style: AppTextStyles.labelLarge
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            if (canGoBack) ...[
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: TextButton(
                                  onPressed: () {
                                    service?.isErrorScreenOpen.value = false;
                                    Navigator.of(context).maybePop();
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    foregroundColor: const Color(0xFF64748B),
                                  ),
                                  child: Text(
                                    LK.goBack.tr,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(NetworkErrorType type) {
    Color bg;
    Color border;
    Color dot;
    String text;

    switch (type) {
      case NetworkErrorType.noInternet:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFCA5A5);
        dot = const Color(0xFFDC2626);
        text = LK.statusOffline.tr;
        break;
      case NetworkErrorType.serverDown:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFCD34D);
        dot = const Color(0xFFD97706);
        text = LK.statusServerMaintenance.tr;
        break;
      case NetworkErrorType.timeout:
        bg = const Color(0xFFEDE9FE);
        border = const Color(0xFFC4B5FD);
        dot = const Color(0xFF7C3AED);
        text = LK.statusTimeout.tr;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: dot,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration(NetworkErrorType type) {
    IconData iconData;
    List<Color> gradientColors;
    Color shadowColor;

    switch (type) {
      case NetworkErrorType.noInternet:
        iconData = Icons.wifi_off_rounded;
        gradientColors = [const Color(0xFFEF4444), const Color(0xFFF87171)];
        shadowColor = const Color(0xFFEF4444).withValues(alpha: 0.25);
        break;
      case NetworkErrorType.serverDown:
        iconData = Icons.cloud_off_rounded;
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
        shadowColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
        break;
      case NetworkErrorType.timeout:
        iconData = Icons.history_toggle_off_rounded;
        gradientColors = [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)];
        shadowColor = const Color(0xFF8B5CF6).withValues(alpha: 0.25);
        break;
    }

    return Container(
      width: 140.w,
      height: 140.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradientColors.first.withValues(alpha: 0.08),
      ),
      child: Center(
        child: Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            iconData,
            size: 56.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticsCard(GlobalNetworkErrorService? service) {
    final type =
        service?.currentErrorType.value ?? NetworkErrorType.serverDown;

    final isInternetConnected = type != NetworkErrorType.noInternet;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16.sp,
                color: const Color(0xFF64748B),
              ),
              SizedBox(width: 8.w),
              Text(
                LK.diagnosticsTitle.tr,
                style: AppTextStyles.labelMedium.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.h),
          _diagnosticRow(
            label: LK.internetStatus.tr,
            status: isInternetConnected ? LK.connected.tr : LK.disconnected.tr,
            isHealthy: isInternetConnected,
          ),
          SizedBox(height: 10.h),
          _diagnosticRow(
            label: LK.serverStatus.tr,
            status: LK.unreachable.tr,
            isHealthy: false,
          ),
        ],
      ),
    );
  }

  Widget _diagnosticRow({
    required String label,
    required String status,
    required bool isHealthy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(
              isHealthy ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 15.sp,
              color: isHealthy
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
            SizedBox(width: 6.w),
            Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isHealthy
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTitle(NetworkErrorType type, String? customTitle) {
    if (customTitle != null && customTitle.isNotEmpty) return customTitle;
    switch (type) {
      case NetworkErrorType.noInternet:
        return LK.noInternetTitle.tr;
      case NetworkErrorType.serverDown:
        return LK.serverDownTitle.tr;
      case NetworkErrorType.timeout:
        return LK.timeoutTitle.tr;
    }
  }

  String _getDescription(NetworkErrorType type, String? customDesc) {
    if (customDesc != null && customDesc.isNotEmpty) return customDesc;
    switch (type) {
      case NetworkErrorType.noInternet:
        return LK.noInternetDesc.tr;
      case NetworkErrorType.serverDown:
        return LK.serverDownDesc.tr;
      case NetworkErrorType.timeout:
        return LK.timeoutDesc.tr;
    }
  }
}
