import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_details_page.dart';

class EventCard extends StatelessWidget {
  final EventsData event;

  const EventCard({Key? key, required this.event}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    DateTime start =
        DateTime.tryParse(event.startDateTime ?? '') ?? DateTime.now();
    DateTime end = DateTime.tryParse(event.endDateTime ?? '') ?? DateTime.now();

    final String timeString = _formatEventDateTime(start, end);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (event.eventId != null) {
              Get.to(() => EventDetailsPage(eventId: event.eventId!));
            }
          },
          child: _buildContent(timeString),
        ),
      ),
    );
  }

  Widget _buildContent(String timeString) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.coverImage != null && event.coverImage!.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              event.coverImage!,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (event.eventType != null &&
                      event.eventType!.isNotEmpty) ...[
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
                  if (event.eventMode != null &&
                      event.eventMode!.isNotEmpty) ...[
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

              if ((event.eventName ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  event.eventName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
              if ((event.translatedEventName ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.translatedEventName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
              if (timeString.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if ((event.venue ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.venue ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if ((event.maximumCapacity ?? 0) > 0) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        (event.totalRegistrations ?? 0) /
                        (event.maximumCapacity ?? 1),
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0C6C5E),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${event.totalRegistrations ?? 0} of ${event.maximumCapacity ?? 0} places taken',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
