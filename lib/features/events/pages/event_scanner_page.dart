/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pscommunitymobileapp/core/network/app_config.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_attendance_controller.dart';
import 'package:pscommunitymobileapp/features/events/repositories/event_attendance_repository_impl.dart';

class EventScannerPage extends StatefulWidget {
  final String? customToken;
  const EventScannerPage({Key? key, this.customToken}) : super(key: key);

  @override
  State<EventScannerPage> createState() => _EventScannerPageState();
}

class _EventScannerPageState extends State<EventScannerPage>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;
  late final Animation<double> _scanAnimation;

  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    if (widget.customToken != null && widget.customToken!.trim().isNotEmpty) {
      EventAttendanceRepositoryImpl.updateToken(widget.customToken!);
    }
    // Fixed back camera view as requested: no camera rotation allowed
    // Using DetectionSpeed.normal so rescan works on the exact same barcode immediately
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isScanned = true;
    });

    try {
      await _scannerController.stop();
    } catch (_) {}

    final attendanceController =
        Get.isRegistered<EventAttendanceController>()
            ? Get.find<EventAttendanceController>()
            : null;

    attendanceController?.handleQrScan(qrData: rawValue);
    _showScanResultBottomSheet(rawValue);
  }

  void _rescan() async {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
    if (Get.isRegistered<EventAttendanceController>()) {
      Get.find<EventAttendanceController>().reset();
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isScanned = false;
      });
      try {
        await _scannerController.start();
      } catch (_) {}
    }
  }

  void _showScanResultBottomSheet(String value) {
    final attendanceController =
        Get.isRegistered<EventAttendanceController>()
            ? Get.find<EventAttendanceController>()
            : null;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Obx(() {
          final bool isLoading =
              attendanceController?.isLoading.value ?? false;
          final bool hasError =
              attendanceController?.hasError.value ?? false;
          final bool isSuccess =
              attendanceController?.isSuccess.value ?? false;
          final String errorMsg =
              attendanceController?.errorMessage.value ?? '';
          final String successMsg =
              attendanceController?.successMessage.value ?? '';
          final scannedMap =
              attendanceController?.scannedData.value ?? {};
          final checkInMap =
              attendanceController?.checkInResponse.value ?? {};

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              if (isLoading) ...[
                // Loading State
                SizedBox(height: 20.h),
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3.5,
                ),
                SizedBox(height: 20.h),
                Text(
                  LK.scanner_verifying_title.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  LK.scanner_verifying_desc.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ] else if (hasError) ...[
                // RED Error State (as explicitly requested by user)
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8E6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEA4335).withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD93025),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  LK.scanner_failed_title.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: const Color(0xFFD93025),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  LK.scanner_failed_subtitle.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 18.h),
                // RED Error Message Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8E6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFF28B82),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFD93025),
                        size: 22,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          errorMsg.isNotEmpty
                              ? errorMsg
                              : LK.scanner_failed_default_msg.tr,
                          style: TextStyle(
                            color: const Color(0xFFC5221F),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'QR: $value',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 22.h),
                // Red Scan Again Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: _rescan,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      LK.scanner_scan_again_btn.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD93025),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    LK.scanner_done_btn.tr,
                    style: TextStyle(
                      color: AppColors.grey.shade600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else if (isSuccess) ...[
                // GREEN Success State
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF34A853).withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8E3E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  LK.scanner_success_title.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: const Color(0xFF1E8E3E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  successMsg.isNotEmpty
                      ? successMsg
                      : LK.scanner_success_subtitle.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade700,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),

                // Scanned Details Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE9ECEF),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        LK.scanner_label_qr_data.tr,
                        value,
                        icon: Icons.qr_code_2_rounded,
                      ),
                      if ((scannedMap['memberName'] ??
                              scannedMap['fullName'] ??
                              checkInMap['memberName'] ??
                              checkInMap['fullName']) !=
                          null) ...[
                        SizedBox(height: 8.h),
                        Divider(
                          height: 1,
                          color: AppColors.grey.shade200,
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          LK.scanner_label_member_name.tr,
                          '${scannedMap['memberName'] ?? scannedMap['fullName'] ?? checkInMap['memberName'] ?? checkInMap['fullName']}',
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                      if ((scannedMap['eventName'] ??
                              checkInMap['eventName']) !=
                          null) ...[
                        SizedBox(height: 8.h),
                        Divider(
                          height: 1,
                          color: AppColors.grey.shade200,
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          LK.scanner_label_event.tr,
                          '${scannedMap['eventName'] ?? checkInMap['eventName']}',
                          icon: Icons.event_available_rounded,
                        ),
                      ],
                      if ((scannedMap['numberOfUsers'] ??
                              scannedMap['numberOfGuests'] ??
                              checkInMap['numberOfUsers']) !=
                          null) ...[
                        SizedBox(height: 8.h),
                        Divider(
                          height: 1,
                          color: AppColors.grey.shade200,
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          LK.scanner_label_attendees.tr,
                          '${scannedMap['numberOfUsers'] ?? scannedMap['numberOfGuests'] ?? checkInMap['numberOfUsers']}',
                          icon: Icons.people_outline_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 22.h),

                // Primary "Scan Next" button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: _rescan,
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: Text(
                      LK.scanner_scan_next_btn.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8E3E),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    LK.scanner_done_btn.tr,
                    style: TextStyle(
                      color: AppColors.grey.shade600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
      isDismissible: true,
      enableDrag: true,
    ).then((_) async {
      if (mounted && _isScanned) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _isScanned = false;
          });
          try {
            await _scannerController.start();
          } catch (_) {}
        }
      }
    });
  }

  Widget _buildDetailRow(String label, String val, {required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E8E3E)),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                val,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowSize = 260.w;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen fixed back camera view
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),

          // Dark overlay with cutout scanner window
          Positioned.fill(
            child: _buildScannerOverlay(scanWindowSize),
          ),

          // Animated laser line inside the scan window
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: scanWindowSize,
                height: scanWindowSize,
                child: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: scanWindowSize * _scanAnimation.value,
                          left: 10.w,
                          right: 10.w,
                          child: Container(
                            height: 3.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF00E676),
                                  Colors.white,
                                  const Color(0xFF00E676),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Helper instruction pill below scan frame
          Positioned(
            bottom: 60.h,
            left: 24.w,
            right: 24.w,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF00E676),
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          LK.scanner_align_instruction.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top Header: Back Button + Circle Avatar + Samaj Name + Flashlight Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Top-Left Circle Avatar + Samaj Name
                          _buildSamajInfo(),

                          // Top-Right Flashlight Toggle Button
                          _buildFlashlightButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamajInfo() {
    final samajController = Get.isRegistered<SamajController>()
        ? Get.find<SamajController>()
        : null;

    return Expanded(
      child: Obx(() {
        final samaj = samajController?.samaj.value;
        final logoUrl = samaj?.logoUrl;
        final samajName = samaj?.name ?? LK.samajName.tr;

        return Row(
          children: [
            // Circle Avatar
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? CachedImg(
                        url: logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => _fallbackLogo(),
                      )
                    : _fallbackLogo(),
              ),
            ),
            SizedBox(width: 10.w),

            // Samaj Name & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    samajName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    LK.scanner_title.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFlashlightButton() {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: _scannerController,
      builder: (context, state, _) {
        final isTorchOn = state.torchState == TorchState.on;

        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            await _scannerController.toggleTorch();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTorchOn
                  ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: isTorchOn
                    ? const Color(0xFFFFD700)
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: isTorchOn
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: isTorchOn ? const Color(0xFFFFD700) : Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackLogo() => Image.asset(FallBackImage, fit: BoxFit.cover);

  Widget _buildScannerOverlay(double windowSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScannerHolePainter(
            windowSize: windowSize,
            cornerColor: const Color(0xFF00E676),
          ),
        );
      },
    );
  }
}

/// Custom painter that dims the surrounding area while leaving a transparent window with stylish corners
class _ScannerHolePainter extends CustomPainter {
  final double windowSize;
  final Color cornerColor;

  _ScannerHolePainter({
    required this.windowSize,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - windowSize) / 2;
    final double top = (size.height - windowSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, windowSize, windowSize);

    // Dim background paint
    final Paint dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      );

    // Combine paths to punch hole
    final Path finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(finalPath, dimPaint);

    // Draw frame border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      borderPaint,
    );

    // Draw stylish L corners
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 26.w;
    final double r = 20.0;

    final double right = left + windowSize;
    final double bottom = top + windowSize;

    // Top-Left Corner
    final Path tlPath = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + r)
      ..arcToPoint(
        Offset(left + r, top),
        radius: const Radius.circular(20),
        clockwise: true,
      )
      ..lineTo(left + cornerLength, top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right Corner
    final Path trPath = Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - r, top)
      ..arcToPoint(
        Offset(right, top + r),
        radius: const Radius.circular(20),
        clockwise: true,
      )
      ..lineTo(right, top + cornerLength);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left Corner (counter-clockwise arc so it curves inwards)
    final Path blPath = Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom - r)
      ..arcToPoint(
        Offset(left + r, bottom),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(left + cornerLength, bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right Corner (counter-clockwise arc so it curves inwards)
    final Path brPath = Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right - r, bottom)
      ..arcToPoint(
        Offset(right, bottom - r),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(right, bottom - cornerLength);
    canvas.drawPath(brPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerHolePainter oldDelegate) {
    return oldDelegate.windowSize != windowSize ||
        oldDelegate.cornerColor != cornerColor;
  }
}
*/