import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/models/event_model.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_details_page.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatTime = DateFormat('h:mm a');
    final formatDate = DateFormat('d MMM yyyy');
    final String timeString =
        '${formatDate.format(event.startTime)}, ${formatTime.format(event.startTime).toLowerCase()} to ${formatTime.format(event.endTime).toLowerCase()}';

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
            Get.to(() => EventDetailsPage(event: event));
          },
          child:_buildContent(timeString),
        ),
      ),
    );
  }

  Widget _buildContent(String timeString) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              event.imageUrl!,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.subCategoryString,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (event.isRegistered) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F5ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Color(0xFF1A7A60)),
                      SizedBox(width: 4),
                      Text(
                        'Registered',
                        style: TextStyle(
                          fontSize: 12,
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
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.gujaratiTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF64748B)),
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
                  event.location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: event.placesTaken / event.totalPlaces,
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
                '${event.placesTaken} of ${event.totalPlaces} places taken',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
        ),
      ],
    );
  }
}

class DiagonalStripesPainter extends CustomPainter {
  final Color bgColor;
  final Color stripeColor;

  DiagonalStripesPainter({required this.bgColor, required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    Paint stripePaint = Paint()
      ..color = stripeColor
      ..strokeWidth = 25
      ..style = PaintingStyle.stroke;

    double step = 50;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
