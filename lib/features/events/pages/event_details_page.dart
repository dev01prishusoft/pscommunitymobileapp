import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_details_controller.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/widgets/app_pdf_viewer_page.dart';
import 'package:pscommunitymobileapp/features/events/controllers/events_controller.dart';

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

        return NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction != ScrollDirection.idle) {
              controller.triggerVideoPause();
            }
            return false;
          },
          child: SingleChildScrollView(
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
                if (event.committeeName != null ||
                    (event.organizerName != null &&
                        event.organizerName!.isNotEmpty) ||
                    (event.organizers != null &&
                        event.organizers!.isNotEmpty)) ...[
                  SizedBox(height: 16.h),
                  _buildOrganisedBySection(event),
                ],
                _buildDocumentsSection(event),
                if ((event.termsAndConditions != null &&
                        event.termsAndConditions!.isNotEmpty) ||
                    (event.shortDescription != null &&
                        event.shortDescription!.isNotEmpty)) ...[
                  SizedBox(height: 16.h),
                  _buildPleaseNoteSection(event),
                ],
              ],
            ).paddingSymmetric(horizontal: 10.w),
          ),
        );
      }),
    );
  }

  Widget _buildMediaCarousel(EventDetailsData event) {
    if (event.medias == null || event.medias!.isEmpty) {
      return const SizedBox.shrink();
    }

    final carouselMedias = event.medias!
        .where((m) => !(m.url?.toLowerCase().contains('.pdf') ?? false))
        .toList();

    if (carouselMedias.isEmpty) return const SizedBox.shrink();

    return EventMediaCarousel(medias: carouselMedias);
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
              spacing: 5,
              runSpacing: 5,
              children: [
                if (event.eventType != null && event.eventType!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
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
                          style: AppTextStyles.labelSmall.copyWith(
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
                      horizontal: 10,
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
                          style: AppTextStyles.labelSmall.copyWith(
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
                      horizontal: 10,
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
                          style: AppTextStyles.labelSmall.copyWith(
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
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F5ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.money,
                          size: 14,
                          color: Color(0xFF1A7A60),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (event.registrationFee == 0 ||
                                  event.registrationFee == 0.0)
                              ? 'Free'
                              : 'Registration Fee ${event.registrationFee}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF1A7A60),
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
            _buildInfoRow(
              Icons.event_seat,
              '${event.totalRegistrations ?? 0} places taken',
            ),
            SizedBox(height: 16.h),
            if (event.maximumGuestsPerMember != 0) ...[
              _buildInfoRow(
                Icons.family_restroom,
                'Up to ${event.maximumGuestsPerMember} Guest members',
              ),
            ],
            if (event.schedules != null && event.schedules!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Divider(color: AppColors.grey.shade100, height: 1),
              SizedBox(height: 16.h),
              eventTimeLine(event),
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
            if (event.organizers != null && event.organizers!.isNotEmpty)
              ...event.organizers!
                  .map((organizer) => _buildOrganizerItem(organizer))
                  .toList()
            else
              _buildLegacyOrganizer(event),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerItem(Organizers organizer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (organizer.committeeName != null &&
            organizer.committeeName!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: Text(
              organizer.committeeName!,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (organizer.memberName != null && organizer.memberName!.isNotEmpty)
          _buildPersonRow(
            organizer.memberName,
            organizer.mobileNo,
            organizer.email,
          ),
        if (organizer.committeeMembers != null &&
            organizer.committeeMembers!.isNotEmpty)
          ...organizer.committeeMembers!.map(
            (member) => _buildPersonRow(
              member.memberName,
              member.mobileNo,
              member.email,
            ),
          ),
      ],
    );
  }

  Widget _buildLegacyOrganizer(EventDetailsData event) {
    return _buildPersonRow(
      event.organizerName,
      event.organizerMobileNo?.toString(),
      null,
    );
  }

  Widget _buildPersonRow(String? name, String? mobile, String? email) {
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: 22.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (mobile != null && mobile.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final url = 'tel:$mobile';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url);
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.call, size: 16.w, color: AppColors.green),
              ),
            ),
          if (email != null && email.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final url = 'mailto:$email';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url);
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.email, size: 16.w, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(EventDetailsData event) {
    if (event.medias == null || event.medias!.isEmpty) {
      return const SizedBox.shrink();
    }

    final pdfMedias = event.medias!
        .where((m) => m.url?.toLowerCase().contains('.pdf') ?? false)
        .toList();

    if (pdfMedias.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16.h),
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
                Icon(
                  Iconsax.document_1_copy,
                  color: AppColors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text('Documents', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Brochures, rule sheets or consent forms members can download.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.grey.shade200),
              ),
              child: Column(
                children: pdfMedias.asMap().entries.map((entry) {
                  final index = entry.key;
                  final media = entry.value;
                  String pdfName = 'Document';
                  try {
                    if (media.url != null) {
                      pdfName = Uri.decodeComponent(media.url!.split('/').last);
                    }
                  } catch (_) {}

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                'PDF',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                pdfName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            TextButton(
                              onPressed: () {
                                if (media.url != null) {
                                  Get.to(
                                    () => AppPdfViewerPage(
                                      title: pdfName,
                                      pdfUrl: media.url!,
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Open',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < pdfMedias.length - 1)
                        Divider(color: AppColors.grey.shade200, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStaticBar(EventDetailsData event) {
    if (event.isMemberRegistered == true) return SizedBox.shrink();
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
            ),
            if (event.isMemberRegistered == false)
              ElevatedButton(
                onPressed: () async {
                  await Get.toNamed(
                    AppRouter.eventRegistration,
                    arguments: event,
                  );
                  if (Get.isRegistered<EventDetailsController>()) {
                    Get.find<EventDetailsController>().fetchEventDetails(
                      isSilent: true,
                    );
                  }
                  if (Get.isRegistered<EventsController>()) {
                    Get.find<EventsController>().refreshEventsSilently();
                  }
                },
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
}

class EventTimelineWidget extends StatelessWidget {
  final List<Schedules> schedules;

  const EventTimelineWidget({Key? key, required this.schedules})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    // Group schedules by date
    Map<DateTime, List<Schedules>> groupedSchedules = {};
    for (var schedule in schedules) {
      DateTime dt =
          DateTime.tryParse(schedule.scheduleStartDateTime ?? '') ??
          DateTime.now();
      DateTime date = DateTime(dt.year, dt.month, dt.day);
      groupedSchedules.putIfAbsent(date, () => []).add(schedule);
    }

    final sortedDates = groupedSchedules.keys.toList()..sort();
    final DateFormat titleDateFormat = DateFormat('EEEE, d MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_rounded, color: AppColors.primary, size: 24.w),
            SizedBox(width: 8.w),
            Text('Event Timeline', style: AppTextStyles.titleMedium),
          ],
        ),
        SizedBox(height: 16.h),
        ...sortedDates.asMap().entries.map((entry) {
          int index = entry.key;
          DateTime date = entry.value;
          List<Schedules> daySchedules = groupedSchedules[date]!;
          daySchedules.sort((a, b) {
            DateTime timeA =
                DateTime.tryParse(a.scheduleStartDateTime ?? '') ??
                DateTime.now();
            DateTime timeB =
                DateTime.tryParse(b.scheduleStartDateTime ?? '') ??
                DateTime.now();
            return timeA.compareTo(timeB);
          });

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  initiallyExpanded: index == 0,
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.grey.shade500,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.02),
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  title: Text(
                    'Day ${index + 1} - ${titleDateFormat.format(date)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: daySchedules.asMap().entries.map((schEntry) {
                          int j = schEntry.key;
                          bool isLastSchedule = j == daySchedules.length - 1;
                          return _buildTimelineItem(
                            context: context,
                            isLast: isLastSchedule,
                            content: _buildScheduleContent(
                              context,
                              schEntry.value,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required Widget content,
    bool isLast = false,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 7.w, top: 6.h),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isLast
                    ? Colors.transparent
                    : AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          padding: EdgeInsets.only(left: 24.w, bottom: isLast ? 0 : 28.h),
          child: content,
        ),
        Positioned(
          left: 0,
          top: 6.h,
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleContent(BuildContext context, Schedules schedule) {
    DateTime startTime =
        DateTime.tryParse(schedule.scheduleStartDateTime ?? '') ??
        DateTime.now();
    DateTime endTime =
        DateTime.tryParse(schedule.scheduleEndDateTime ?? '') ??
        startTime.add(const Duration(hours: 1));
    final formatTime = DateFormat('h:mm a');
    String timeString =
        '${formatTime.format(startTime).toLowerCase()} to ${formatTime.format(endTime).toLowerCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeString,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          schedule.sessionName ?? 'Session',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (schedule.speakerName != null &&
            schedule.speakerName!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.person, size: 16.w, color: AppColors.grey.shade500),
              SizedBox(width: 6.w),
              Text(
                schedule.speakerName!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
        if (schedule.sessionDescription != null &&
            schedule.sessionDescription!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            schedule.sessionDescription!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
        if ((schedule.scheduleVenueName != null &&
                schedule.scheduleVenueName!.isNotEmpty) ||
            '${schedule.scheduleAddressLine1 ?? ''} ${schedule.scheduleAddressLine2 ?? ''} ${schedule.scheduleLandmark ?? ''} ${schedule.schedulePincode ?? ''}'
                .trim()
                .isNotEmpty) ...[
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 16.w,
                color: AppColors.grey.shade500,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (schedule.scheduleVenueName != null &&
                              schedule.scheduleVenueName!.isNotEmpty)
                            Text(
                              schedule.scheduleVenueName!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if ('${schedule.scheduleAddressLine1 ?? ''} ${schedule.scheduleAddressLine2 ?? ''} ${schedule.scheduleLandmark ?? ''} ${schedule.schedulePincode ?? ''}'
                              .trim()
                              .isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              '${schedule.scheduleAddressLine1 ?? ''} ${schedule.scheduleAddressLine2 ?? ''} ${schedule.scheduleLandmark ?? ''} ${schedule.schedulePincode ?? ''}'
                                  .trim(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (schedule.scheduleGoogleMapUrl != null &&
                        schedule.scheduleGoogleMapUrl!.isNotEmpty) ...[
                      IconButton(
                        onPressed: () async {
                          String? url = schedule.scheduleGoogleMapUrl;
                          if (url == null) return;
                          if (Platform.isIOS) {
                            String address =
                                '${schedule.scheduleVenueName ?? ''} ${schedule.scheduleAddressLine1 ?? ''} ${schedule.scheduleLandmark ?? ''} ${schedule.schedulePincode ?? ''}'
                                    .trim();
                            if (address.isNotEmpty) {
                              url =
                                  'http://maps.apple.com/?q=${Uri.encodeComponent(address)}';
                            }
                          }
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (Platform.isIOS &&
                              await canLaunchUrlString(
                                schedule.scheduleGoogleMapUrl!,
                              )) {
                            await launchUrlString(
                              schedule.scheduleGoogleMapUrl!,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: Icon(Icons.directions, size: 20.w),
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(
                            AppColors.primary,
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.primary.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
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
                  thumbnailUrl: media.thumbnailUrl,
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
              (m) =>
                  m.type?.toLowerCase() != 'video' &&
                  !(m.url?.toLowerCase().contains('.pdf') ?? false),
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
  final String? thumbnailUrl;
  final bool isActive;

  const EventVideoPlayerWidget({
    Key? key,
    required this.url,
    this.thumbnailUrl,
    required this.isActive,
  }) : super(key: key);

  @override
  State<EventVideoPlayerWidget> createState() => _EventVideoPlayerWidgetState();
}

class _EventVideoPlayerWidgetState extends State<EventVideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Worker? _pauseWorker;
  bool _hasStartedPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    if (Get.isRegistered<EventDetailsController>()) {
      _pauseWorker = ever(
        Get.find<EventDetailsController>().pauseVideoTrigger,
        (_) {
          if (_videoPlayerController.value.isInitialized &&
              _videoPlayerController.value.isPlaying) {
            _videoPlayerController.pause();
          }
        },
      );
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    // Listen to video state to hide thumbnail if played via other means
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isPlaying && !_hasStartedPlaying) {
        if (mounted) {
          setState(() {
            _hasStartedPlaying = true;
          });
        }
      }
    });

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      allowMuting: true,
      showControls: true,
      showOptions: false,
      allowPlaybackSpeedChanging: false,
      overlay: widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty
          ? ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoPlayerController,
              builder: (context, value, child) {
                if (value.isPlaying || value.position > Duration.zero) {
                  return const SizedBox.shrink();
                }
                return SizedBox.expand(
                  child: Image.network(widget.thumbnailUrl!, fit: BoxFit.cover),
                );
              },
            )
          : null,
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
      if (!widget.isActive) {
        _videoPlayerController.pause();
      }
    }
  }

  @override
  void dispose() {
    _pauseWorker?.dispose();
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
      if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.thumbnailUrl!, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.3)),
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
  }
}
