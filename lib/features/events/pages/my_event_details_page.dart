import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pscommunitymobileapp/core/models/registered_event_details_model.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/events/controllers/my_event_details_controller.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class MyEventDetailsPage extends StatelessWidget {
  final int eventRegistrationId;
  final RegisteredEventItem? initialItem;

  const MyEventDetailsPage({
    Key? key,
    required this.eventRegistrationId,
    this.initialItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      MyEventDetailsController(
        repository: Get.find<EventsRepositories>(),
        registrationId: eventRegistrationId.toString(),
        initialItem: initialItem,
      ),
      tag: eventRegistrationId.toString(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(LK.event_reg_title.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.detail.value == null) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.hasError.value && controller.detail.value == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.w,
                    color: AppColors.red,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : LK.my_event_details_load_err.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => controller.fetchDetail(isRefresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      LK.retry.tr,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final RegisteredEventsDetailsData? detail = controller.detail.value;

        // Resolve display values from detail API or initialItem fallback
        final String eventName =
            detail?.eventName ??
            initialItem?.eventName ??
            LK.event_details_title.tr;

        final String dateTimeStr = _formatDateTime(
          startStr:
              detail?.eventStartDateTime ?? initialItem?.eventStartDateTime,
          endStr: detail?.eventEndDateTime ?? initialItem?.eventEndDateTime,
          timePeriod: detail?.timePeriod ?? initialItem?.timePeriod,
          registeredAt: detail?.registeredAt ?? initialItem?.registeredAt,
          createdAt: detail?.createdAt ?? initialItem?.createdAt,
        );

        final bool isCancelled =
            (detail?.cancelledAt != null) ||
            (initialItem?.cancelledAt != null) ||
            (detail?.cancellationReason != null &&
                detail!.cancellationReason.toString().isNotEmpty) ||
            (initialItem?.cancellationReason != null &&
                initialItem!.cancellationReason.toString().isNotEmpty) ||
            (detail?.registrationStatusName ??
                    initialItem?.registrationStatusName ??
                    '')
                .toLowerCase()
                .contains('cancel');

        final String statusName = isCancelled
            ? 'cancelled'
            : (detail?.registrationStatusName ??
                      initialItem?.registrationStatusName ??
                      'registered')
                  .toLowerCase();

        final (badgeTextColor, badgeBgColor) = _getStatusBadgeColors(
          statusName,
        );

        final String registrationNumber =
            detail?.registrationNumber ??
            initialItem?.registrationNumber ??
            detail?.eventCode ??
            initialItem?.eventCode ??
            'REG-$eventRegistrationId';

        final String memberName =
            detail?.memberName ??
            initialItem?.memberName ??
            LK.my_event_details_member_default.tr;
        final String memberNo = detail?.memberNo ?? initialItem?.memberNo ?? '';

        final detailGuests = detail?.guests;
        final guests = (detailGuests != null && detailGuests.isNotEmpty)
            ? detailGuests
            : initialItem?.guests;
        final int? numberOfGuests =
            detail?.numberOfGuests ?? initialItem?.numberOfGuests;
        final String? guestsText = _formatGuests(
          guests,
          numberOfGuests: numberOfGuests,
        );

        final fullAddress =
            '${detail?.venueName ?? initialItem?.venueName ?? ''} ${detail?.venueAddress ?? initialItem?.venueAddress ?? ''}';

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // Ticket style card exactly matching user's design
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE9ECEF),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top header: Event Name, Date/Time, Status Badge
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 18.h),
                      child: Column(
                        children: [
                          Text(
                            eventName,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (dateTimeStr.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Text(
                              dateTimeStr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              statusName.toUpperCase(),
                              style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dotted / Dashed line separator
                    const _DashedDivider(color: Color(0xFFE5E7EB), height: 1.5),

                    // QR Code Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        children: [
                          // QR container with rounded border
                          Container(
                            width: 222.w,
                            height: 222.w,
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                            ),
                            child: _buildQrCodeWidget(detail?.qrCodeData),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            LK.my_event_details_reg_number.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SelectableText(
                            registrationNumber,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFFF3F4F6),
                    ),

                    // Member Info Row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          memberNo.isNotEmpty
                              ? '$memberName · $memberNo'
                              : memberName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),

                    // Guests Row (matching design screenshot)
                    if (guestsText != null && guestsText.isNotEmpty) ...[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: const Color(0xFFF3F4F6),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            guestsText,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Venue Row (Name & Address with Google Maps link)
                    if (fullAddress.isNotEmpty) ...[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: const Color(0xFFF3F4F6),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                fullAddress,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF4B5563),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              onPressed: () => _openMap(
                                mapUrl:
                                    detail?.venueGoogleMapUrl?.toString() ??
                                    initialItem?.venueGoogleMapUrl?.toString(),
                                latitude: detail?.venueLatitude,
                                longitude: detail?.venueLongitude,
                                address: fullAddress,
                              ),
                              icon: Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 20.w,
                                  color: AppColors.primary,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: LK.my_event_details_open_maps.tr,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (!isCancelled) ...[
                SizedBox(height: 22.h),

                // Outlined Button: "Cancel My Registration" (red border and red text)
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () =>
                        _showCancelConfirmation(context, controller),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(
                      LK.my_event_details_cancel_btn.tr,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  String _formatDateTime({
    String? startStr,
    String? endStr,
    dynamic timePeriod,
    String? registeredAt,
    String? createdAt,
  }) {
    if (startStr != null && startStr.isNotEmpty) {
      final start = DateTime.tryParse(startStr);
      final end = endStr != null ? DateTime.tryParse(endStr) : null;
      if (start != null) {
        final dateStr = DateFormat('d MMM yyyy').format(start);
        final startTimeStr = DateFormat('h:mm a').format(start).toLowerCase();
        if (end != null) {
          final endTimeStr = DateFormat('h:mm a').format(end).toLowerCase();
          return '$dateStr, $startTimeStr to $endTimeStr';
        }
        return '$dateStr, $startTimeStr';
      }
    }

    if (timePeriod != null && timePeriod.toString().isNotEmpty) {
      return timePeriod.toString();
    }

    final fallback = registeredAt ?? createdAt;
    if (fallback != null && fallback.isNotEmpty) {
      final dt = DateTime.tryParse(fallback);
      if (dt != null) {
        return DateFormat('d MMM yyyy, h:mm a').format(dt).toLowerCase();
      }
    }
    return '';
  }

  (Color textColor, Color bgColor) _getStatusBadgeColors(String status) {
    final s = status.toLowerCase();
    if (s.contains('cancel')) {
      return (AppColors.error, AppColors.errorLight);
    } else if (s.contains('register')) {
      return (AppColors.success, AppColors.successLight);
    } else {
      return (AppColors.neutral, AppColors.neutralLight);
    }
  }

  String? _formatGuests(List<Guests>? guests, {int? numberOfGuests}) {
    if (guests != null && guests.isNotEmpty) {
      final guestStrings = guests
          .map((g) {
            final name = (g.guestName?.isNotEmpty == true)
                ? g.guestName!.trim()
                : (g.memberName?.isNotEmpty == true)
                ? g.memberName!.trim()
                : '';
            if (name.isEmpty) return '';
            final age = (g.age != null && g.age! > 0) ? ' (${g.age})' : '';
            return '$name$age';
          })
          .where((s) => s.isNotEmpty)
          .toList();

      if (guestStrings.isNotEmpty) {
        return '${LK.my_event_details_with_prefix.tr} ${guestStrings.join(', ')}';
      }
    }
    if (numberOfGuests != null && numberOfGuests > 0) {
      return '${LK.my_event_details_with_prefix.tr} $numberOfGuests ${numberOfGuests == 1 ? LK.my_event_guest.tr : LK.my_event_guests.tr}';
    }
    return null;
  }

  void _showCancelConfirmation(
    BuildContext context,
    MyEventDetailsController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Obx(() {
          final isCancelling = controller.isCancelling.value;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: AppColors.white,
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    LK.cancel_registration.tr,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              LK.my_event_details_dialog_msg.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey.shade700,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isCancelling
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: AppColors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        LK.no.tr,
                        style: TextStyle(
                          color: AppColors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCancelling
                          ? null
                          : () async {
                              final success = await controller
                                  .cancelRegistration();
                              Navigator.of(dialogContext).pop();
                              if (success) {
                                PSDelightToastBar(
                                  builder: (context) => ToastCard(
                                    title:
                                        LK.my_event_details_cancel_success.tr,
                                    isErrorMessage: false,
                                  ),
                                ).show();
                                Get.back(result: true);
                              } else {
                                PSDelightToastBar(
                                  builder: (context) => ToastCard(
                                    title:
                                        controller.errorMessage.value.isNotEmpty
                                        ? controller.errorMessage.value
                                        : LK.my_event_details_cancel_failed.tr,
                                    isErrorMessage: true,
                                  ),
                                ).show();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: AppColors.error,
                        disabledBackgroundColor: AppColors.error.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: isCancelling
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              LK.yes.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _openMap({
    String? mapUrl,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    String? targetUrl;
    if (mapUrl != null && mapUrl.trim().isNotEmpty) {
      targetUrl = mapUrl.trim();
    } else if (latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0) {
      targetUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    } else if (address != null && address.trim().isNotEmpty) {
      targetUrl =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}';
    }

    if (targetUrl != null && await canLaunchUrlString(targetUrl)) {
      await launchUrlString(targetUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(LK.error.tr, LK.my_event_details_map_error.tr);
    }
  }

  Widget _buildQrCodeWidget(String? qrData) {
    if (qrData == null || qrData.trim().isEmpty) {
      return _buildQrPlaceholder();
    }

    final trimmed = qrData.trim();

    // Case 1: Base64 data URI (e.g. data:image/png;base64,iVBOR...)
    if (trimmed.startsWith('data:image') || trimmed.contains('base64,')) {
      try {
        final base64Part = trimmed.split('base64,').last.trim();
        final Uint8List bytes = base64Decode(base64Part);
        return Image.memory(
          bytes,
          height: 200.h,
          width: 200.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
        );
      } catch (_) {
        return _buildQrPlaceholder();
      }
    }

    // Case 2: Remote HTTP/HTTPS image URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        height: 200.h,
        width: 200.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
      );
    }

    // Case 3: Raw base64 string
    try {
      final Uint8List bytes = base64Decode(trimmed);
      return Image.memory(
        bytes,
        height: 200.h,
        width: 200.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
      );
    } catch (_) {
      // Case 4: Plain text QR data (render using QrImageView)
      return QrImageView(
        data: trimmed,
        version: QrVersions.auto,
        size: 200.h,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
      );
    }
  }

  Widget _buildQrPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_2_rounded,
          size: 56.w,
          color: AppColors.grey.shade400,
        ),
        SizedBox(height: 10.h),
        Text(
          LK.my_event_details_qr_na.tr,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Custom dashed divider widget for realistic ticket perforation effect
class _DashedDivider extends StatelessWidget {
  const _DashedDivider({this.height = 1, this.color = const Color(0xFFE0E0E0)});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
