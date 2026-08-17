import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_details_controller.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class EventDetailsPage extends StatelessWidget {
  final int eventId;

  const EventDetailsPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventDetailsController(eventId, Get.find()));

    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.hasError.value)
          return const SizedBox.shrink();
        return _buildBottomStaticBar(controller.eventDetails.value!);
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(child: Text(controller.errorMessage.value));
        }
        final event = controller.eventDetails.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 50.h, top: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaCarousel(event),
              if (event.medias != null && event.medias!.isNotEmpty)
                SizedBox(height: 16.h),
              eventHeaderDetails(event),
              SizedBox(height: 16.h),
              eventInfo(event),
              if (event.schedules != null && event.schedules!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                eventTimeLine(event),
              ],
              if (event.committeeName != null ||
                  (event.organizerName != null &&
                      event.organizerName!.isNotEmpty)) ...[
                SizedBox(height: 16.h),
                _buildOrganisedBySection(event),
              ],
              if ((event.termsAndConditions != null &&
                      event.termsAndConditions!.isNotEmpty) ||
                  (event.shortDescription != null &&
                      event.shortDescription!.isNotEmpty)) ...[
                SizedBox(height: 16.h),
                _buildPleaseNoteSection(event),
              ],
            ],
          ).paddingSymmetric(horizontal: 16.w),
        );
      }),
    );
  }

  String _formatEventDateTime(DateTime start, DateTime end) {
    final formatTime = DateFormat('h:mm a');
    final formatDate = DateFormat('d MMM yyyy');

    final isSameDay =
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (isSameDay) {
      return '${formatDate.format(start)}, ${formatTime.format(start).toLowerCase()} to ${formatTime.format(end).toLowerCase()}';
    } else {
      return '${formatDate.format(start)}, ${formatTime.format(start).toLowerCase()} to ${formatDate.format(end)}, ${formatTime.format(end).toLowerCase()}';
    }
  }

  Widget _buildMediaCarousel(EventDetailsData event) {
    if (event.medias == null || event.medias!.isEmpty)
      return const SizedBox.shrink();

    return EventMediaCarousel(medias: event.medias!);
  }

  Widget eventHeaderDetails(EventDetailsData event) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (event.eventType != null && event.eventType!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.eventType ?? 'Event',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.eventMode != null && event.eventMode!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.confirmation_num,
                          size: 14,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.eventMode}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.isMemberRegistered == true) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Registered',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: const Color(0xFFE65100),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.registrationFee != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F5ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.money, size: 14, color: Color(0xFF1A7A60)),
                        SizedBox(width: 4),
                        Text(
                          'Registration Fee ${event.registrationFee}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Color(0xFF1A7A60),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (event.eventName != null && event.eventName!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                event.eventName!,
                style: AppTextStyles.titleLarge.copyWith(height: 1.2),
              ),
            ],
            if (event.translatedEventName != null &&
                event.translatedEventName!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                event.translatedEventName!,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.grey.shade600,
                ),
              ),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Divider(color: AppColors.grey.shade100, height: 1),
              SizedBox(height: 20.h),
              Text(
                event.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget eventInfo(EventDetailsData event) {
    DateTime start =
        DateTime.tryParse(event.startDateTime ?? '') ?? DateTime.now();
    DateTime end = DateTime.tryParse(event.endDateTime ?? '') ?? DateTime.now();

    final String timeString = _formatEventDateTime(start, end);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20.w),
                SizedBox(width: 8.w),
                Text('Event Details', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: 20.h),
            _buildInfoRow(Icons.access_time_filled, timeString),
            if ((event.venueName != null && event.venueName!.isNotEmpty) ||
                '${event.addressLine1 ?? ''} ${event.addressLine2 ?? ''} ${event.landmark ?? ''} ${event.pincode ?? ''}'
                    .trim()
                    .isNotEmpty) ...[
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20.w,
                    color: AppColors.grey.shade500,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.venueName != null &&
                            event.venueName!.isNotEmpty) ...[
                          Text(
                            event.venueName!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                        if ('${event.addressLine1 ?? ''} ${event.addressLine2 ?? ''} ${event.landmark ?? ''} ${event.pincode ?? ''}'
                            .trim()
                            .isNotEmpty) ...[
                          Text(
                            '${event.addressLine1 ?? ''} ${event.addressLine2 ?? ''} ${event.landmark ?? ''} ${event.pincode ?? ''}'
                                .trim(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],
                        if (event.googleMapUrl != null &&
                            event.googleMapUrl!.isNotEmpty)
                          GestureDetector(
                            onTap: () async {
                              if (await canLaunchUrlString(
                                event.googleMapUrl!,
                              )) {
                                await launchUrlString(event.googleMapUrl!);
                              }
                            },
                            child: Text(
                              'Get directions',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoRow(
                Icons.event_seat,
                '${event.totalRegistrations ?? 0} places taken',
              ),
              SizedBox(height: 16.h),
              _buildInfoRow(
                Icons.family_restroom,
                'Up to ${event.maximumGuestsPerMember} family members',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.w, color: AppColors.grey.shade500),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
          ),
        ),
      ],
    );
  }

  Widget eventTimeLine(EventDetailsData event) {
    if (event.schedules == null || event.schedules!.isEmpty) {
      return const SizedBox.shrink();
    }
    return EventTimelineWidget(schedules: event.schedules!);
  }

  Widget _buildPleaseNoteSection(EventDetailsData event) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.red, size: 16.w),
                SizedBox(width: 8.w),
                Text(
                  'Please Note',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              (event.termsAndConditions != null &&
                      event.termsAndConditions!.isNotEmpty)
                  ? event.termsAndConditions!
                  : (event.shortDescription ?? ''),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.red,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganisedBySection(EventDetailsData event) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: AppColors.primary, size: 20.w),
                SizedBox(width: 8.w),
                Text('Organised By', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.group,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.committeeName?.toString() ?? 'Organizer',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      if (event.organizerName != null &&
                          event.organizerName!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          event.organizerName!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.call, size: 16.w, color: AppColors.green),
                      SizedBox(width: 6.w),
                      Text(
                        'Call',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStaticBar(EventDetailsData event) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.isMemberRegistered == true) ...[
                  Text(
                    'Registration 0184',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16.w,
                        color: AppColors.green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Registered',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Status',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Not registered',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ],
            ),
            if (event.isMemberRegistered == true)
              ElevatedButton.icon(
                onPressed: () => _showPassBottomSheet(Get.context!, event),
                icon: Icon(Icons.qr_code, size: 18.w, color: AppColors.white),
                label: Text(
                  'View Pass',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Register',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPassBottomSheet(BuildContext context, EventDetailsData event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime start =
            DateTime.tryParse(event.startDateTime ?? '') ?? DateTime.now();
        DateTime end =
            DateTime.tryParse(event.endDateTime ?? '') ?? DateTime.now();
        final String timeString = _formatEventDateTime(start, end);

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.grey.shade50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                  width: 48.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade300,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: AppColors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            // Ticket Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.eventName ?? '',
                                        style: AppTextStyles.titleMedium
                                            .copyWith(fontSize: 15.sp),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12.w,
                                            color: AppColors.grey.shade600,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              timeString,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.grey.shade700,
                                                    fontSize: 11.sp,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14.w,
                                        color: AppColors.green,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Registered',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: AppColors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).paddingAll(16.w),
                            Divider(
                              color: AppColors.grey.shade200,
                              height: 1,
                              thickness: 1,
                            ),
                            // QR Code & Details
                            Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: AppColors.grey.shade100,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withValues(
                                            alpha: 0.02,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.qr_code_2,
                                      size: 180.w,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  _buildTicketDetailRow(
                                    'Attendee',
                                    'Kirit Vasa',
                                    'SM-004821',
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow(
                                    'Registration No',
                                    'EDU-MELAVDO-2026/0184',
                                    '',
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow(
                                    'Additional',
                                    'Hetal Vasa (44)',
                                    'Dhruv Vasa (17)',
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow(
                                    'Venue',
                                    'Vidya Bhavan Hall',
                                    'Samaj Bhavan, Chandavarkar Road 400092',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Show this at the check-in desk. It works without internet.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.red.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: AppColors.red.withValues(
                              alpha: 0.02,
                            ),
                          ),
                          child: Text(
                            'Cancel Registration',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).paddingSymmetric(horizontal: 16.w),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              // Fixed Bottom Bar for Bottom Sheet
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration 0184',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14.w,
                                color: AppColors.green,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Registered',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketDetailRow(String label, String value1, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value1,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.black,
                  fontSize: 13.sp,
                ),
              ),
              if (value2.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  value2,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEvent {
  final DateTime dateTime;
  final String title;

  _TimelineEvent({required this.dateTime, required this.title});
}

class EventTimelineWidget extends StatefulWidget {
  final List<Schedules> schedules;

  const EventTimelineWidget({Key? key, required this.schedules})
    : super(key: key);

  @override
  State<EventTimelineWidget> createState() => _EventTimelineWidgetState();
}

class _EventTimelineWidgetState extends State<EventTimelineWidget> {
  late ScrollController _scrollController;
  late List<_TimelineEvent> events;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();

    events = widget.schedules.map((schedule) {
      return _TimelineEvent(
        dateTime:
            DateTime.tryParse(schedule.scheduleStartDateTime ?? '') ??
            DateTime.now(),
        title: schedule.sessionName ?? '',
      );
    }).toList();

    // Ensure chronological order
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    _calculateActiveIndex();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _calculateActiveIndex() {
    if (events.isEmpty) return;

    DateTime now = DateTime.now();
    int closestIndex = 0;
    Duration minDifference = (now.difference(events[0].dateTime)).abs();

    for (int i = 1; i < events.length; i++) {
      Duration difference = (now.difference(events[i].dateTime)).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }

    _activeIndex = closestIndex;
  }

  void _scrollToCurrentTime() {
    if (events.length <= 1) return;

    int targetScrollIndex = _activeIndex >= 0 ? _activeIndex : 0;

    if (_scrollController.hasClients) {
      double itemWidth = 110.w;
      double screenWidth = MediaQuery.of(context).size.width;
      // Calculate offset to center the target item
      double offset =
          (targetScrollIndex * itemWidth) -
          (screenWidth / 2) +
          (itemWidth / 2) +
          16.w;

      if (offset < 0) offset = 0;
      if (offset > _scrollController.position.maxScrollExtent) {
        offset = _scrollController.position.maxScrollExtent;
      }

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text('Event Timeline', style: AppTextStyles.titleMedium),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            if (events.length == 1)
              Center(child: _buildSingleTimelineItem(events.first))
            else
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(events.length, (index) {
                    final event = events[index];
                    return _buildHorizontalTimelineItem(
                      event,
                      isFirst: index == 0,
                      isLast: index == events.length - 1,
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTimelineItem(_TimelineEvent event) {
    final formatTime = DateFormat('h:mm a');
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.event_available,
              color: AppColors.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        formatTime.format(event.dateTime).toLowerCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimelineItem(
    _TimelineEvent event, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final formatTime = DateFormat('h:mm a');

    int currentIndex = events.indexOf(event);
    bool isCurrent = currentIndex == _activeIndex;

    return SizedBox(
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 24.w,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2.h,
                    color: isFirst
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                Container(
                  width: isCurrent ? 20.w : 14.w,
                  height: isCurrent ? 20.w : 14.w,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary : AppColors.white,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.primary,
                      width: isCurrent ? 6 : 3,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : null,
                  ),
                  child: isCurrent
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Container(
                    height: 2.h,
                    color: isLast
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCurrent ? 14.w : 10.w,
              vertical: isCurrent ? 6.h : 4.h,
            ),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100.r),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              formatTime.format(event.dateTime).toLowerCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: isCurrent ? AppColors.white : AppColors.primary,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                fontSize: isCurrent ? 12.sp : null,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              event.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.black,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                fontSize: isCurrent ? 13.sp : null,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventMediaCarousel extends StatefulWidget {
  final List<Medias> medias;

  const EventMediaCarousel({Key? key, required this.medias}) : super(key: key);

  @override
  State<EventMediaCarousel> createState() => _EventMediaCarouselState();
}

class _EventMediaCarouselState extends State<EventMediaCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.medias.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.medias.length,
          itemBuilder: (context, index, realIndex) {
            final media = widget.medias[index];
            final bool isVideo = media.type?.toLowerCase() == 'video';

            if (isVideo && media.url != null) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.black,
                ),
                child: EventVideoPlayerWidget(
                  url: media.url!,
                  isActive: _currentIndex == index,
                ),
              );
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColors.grey.shade200,
                image: media.url != null
                    ? DecorationImage(
                        image: NetworkImage(media.url!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: media.url == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey.shade400,
                        size: 40.w,
                      ),
                    )
                  : null,
            );
          },
          options: CarouselOptions(
            height: 200.h,
            autoPlay: widget.medias.every(
              (m) => m.type?.toLowerCase() != 'video',
            ),
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            enableInfiniteScroll: widget.medias.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        if (widget.medias.length > 1) ...[
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.medias.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: _currentIndex == index ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class EventVideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool isActive;

  const EventVideoPlayerWidget({
    Key? key,
    required this.url,
    required this.isActive,
  }) : super(key: key);

  @override
  State<EventVideoPlayerWidget> createState() => _EventVideoPlayerWidgetState();
}

class _EventVideoPlayerWidgetState extends State<EventVideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: widget.isActive,
      looping: false,
      allowMuting: true,
      showControls: true,
      showOptions: false,
      allowPlaybackSpeedChanging: false,
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant EventVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _videoPlayerController.play();
      } else {
        _videoPlayerController.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
