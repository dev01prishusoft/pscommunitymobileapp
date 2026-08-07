import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/models/event_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      bottomNavigationBar: _buildBottomStaticBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 50.h, top: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            eventHeaderDetails(),
            SizedBox(height: 16.h),
            eventInfo(),
            SizedBox(height: 16.h),
            eventTimeLine(),
            SizedBox(height: 16.h),
            _buildOrganisedBySection(),
            SizedBox(height: 16.h),
            _buildPleaseNoteSection(),
          ],
        ).paddingSymmetric(horizontal: 16.w),
      ),
    );
  }

  Widget eventHeaderDetails() {
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_circle, size: 14.w, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'In person',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_num, size: 14.w, color: AppColors.green),
                      SizedBox(width: 4.w),
                      Text(
                        'Free',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.green, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(event.title, style: AppTextStyles.titleLarge.copyWith(height: 1.2)),
            SizedBox(height: 6.h),
            Text(
              event.gujaratiTitle,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey.shade600),
            ),
            SizedBox(height: 20.h),
            Divider(color: AppColors.grey.shade100, height: 1),
            SizedBox(height: 20.h),
            Text(
              'The education committee will felicitate students who have done well in their exams this year.\n\nPlease arrive by 9:30 am. The programme begins at 10:00 am sharp. Tea on arrival, lunch after the felicitation.\n\nThe afternoon session covers stream selection after standard 10 and 12, education loans and government scholarships.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey.shade700, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventInfo() {
    final formatTime = DateFormat('h:mm a');
    final formatDate = DateFormat('d MMM yyyy');

    final String timeString =
        '${formatDate.format(event.startTime)}, ${formatTime.format(event.startTime).toLowerCase()} to ${formatTime.format(event.endTime).toLowerCase()}';

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
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20.w, color: AppColors.grey.shade500),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.location,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Samaj Bhavan, Chandavarkar Road 400092',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey.shade600),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Get directions',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(Icons.event_seat, '${event.placesTaken} of ${event.totalPlaces} places taken'),
            SizedBox(height: 16.h),
            _buildInfoRow(Icons.family_restroom, 'Up to 3 family members'),
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

  Widget eventTimeLine() {
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
                  Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('Event Timeline', style: AppTextStyles.titleMedium),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHorizontalTimelineItem('9:30 am', 'Registration & tea', isFirst: true),
                  _buildHorizontalTimelineItem('10:15 am', 'Deep prakatya'),
                  _buildHorizontalTimelineItem('10:45 am', 'Felicitation 10/12'),
                  _buildHorizontalTimelineItem('12:30 pm', 'Felicitation graduates'),
                  _buildHorizontalTimelineItem('1:15 pm', 'Lunch'),
                  _buildHorizontalTimelineItem('2:15 pm', 'Career guidance'),
                  _buildHorizontalTimelineItem('3:30 pm', 'Loans & scholarships'),
                  _buildHorizontalTimelineItem('4:30 pm', 'Vote of thanks', isLast: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTimelineItem(String time, String title, {bool isFirst = false, bool isLast = false}) {
    return SizedBox(
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2.h,
                  color: isFirst ? Colors.transparent : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.primary, width: 3),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  height: 2.h,
                  color: isLast ? Colors.transparent : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              time,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPleaseNoteSection() {
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
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.red),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Registration closes one week before so certificates can be printed. Carry your event pass and a copy of your marksheet. Seating is not guaranteed after 10:00 am.',
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

  Widget _buildOrganisedBySection() {
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
                  child: Icon(Icons.group, color: AppColors.primary, size: 24.w),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Education Committee',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.black),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Bhavesh Mehta',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.green, fontWeight: FontWeight.w600),
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

  Widget _buildBottomStaticBar() {
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
                if (event.isRegistered) ...[
                  Text(
                    'Registration 0184',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey.shade500),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16.w, color: AppColors.green),
                      SizedBox(width: 4.w),
                      Text(
                        'Registered',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.black),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Status',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey.shade500),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Not registered',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.black),
                  ),
                ],
              ],
            ),
            if (event.isRegistered)
              ElevatedButton.icon(
                onPressed: () => _showPassBottomSheet(Get.context!),
                icon: Icon(Icons.qr_code, size: 18.w, color: AppColors.white),
                label: Text('View Pass', style: AppTextStyles.labelLarge.copyWith(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
                child: Text('Register', style: AppTextStyles.labelLarge.copyWith(color: AppColors.white)),
              ),
          ],
        ),
      ),
    );
  }

  void _showPassBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formatTime = DateFormat('h:mm a');
        final formatDate = DateFormat('d MMM yyyy');
        final String timeString =
            '${formatDate.format(event.startTime)}, ${formatTime.format(event.startTime).toLowerCase()} to ${formatTime.format(event.endTime).toLowerCase()}';

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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event.title, style: AppTextStyles.titleMedium.copyWith(fontSize: 15.sp)),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12.w, color: AppColors.grey.shade600),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              timeString,
                                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey.shade700, fontSize: 11.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 14.w, color: AppColors.green),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Registered',
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.green, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).paddingAll(16.w),
                            Divider(color: AppColors.grey.shade200, height: 1, thickness: 1),
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
                                      border: Border.all(color: AppColors.grey.shade100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withValues(alpha: 0.02),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.qr_code_2, size: 180.w, color: AppColors.black),
                                  ),
                                  SizedBox(height: 15.h),
                                  _buildTicketDetailRow('Attendee', 'Kirit Vasa', 'SM-004821'),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow('Registration No', 'EDU-MELAVDO-2026/0184', ''),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow('Additional', 'Hetal Vasa (44)', 'Dhruv Vasa (17)'),
                                  SizedBox(height: 10.h),
                                  _buildTicketDetailRow('Venue', 'Vidya Bhavan Hall', 'Samaj Bhavan, Chandavarkar Road 400092'),
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
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey.shade500),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.red.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: AppColors.red.withValues(alpha: 0.02),
                          ),
                          child: Text(
                            'Cancel Registration',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.red, fontWeight: FontWeight.w600),
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
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey.shade500),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.check_circle, size: 14.w, color: AppColors.green),
                              SizedBox(width: 4.w),
                              Text('Registered', style: AppTextStyles.titleSmall.copyWith(color: AppColors.black)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        ),
                        child: Text(
                          'Close',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
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
          child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey.shade500)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value1, style: AppTextStyles.titleMedium.copyWith(color: AppColors.black, fontSize: 13.sp)),
              if (value2.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(value2, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey.shade600, fontSize: 11.sp)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
