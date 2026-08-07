import 'package:flutter/material.dart';

enum EventCategory { educational, medicalCamp, other }

class EventModel {
  final String id;
  final String title;
  final String gujaratiTitle;
  final EventCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int totalPlaces;
  final int placesTaken;
  final bool isRegistered;
  final String status;

  EventModel({
    required this.id,
    required this.title,
    required this.gujaratiTitle,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.totalPlaces,
    required this.placesTaken,
    this.isRegistered = false,
    required this.status,
  });

  String get categoryString {
    switch (category) {
      case EventCategory.educational:
        return 'EDUCATIONAL';
      case EventCategory.medicalCamp:
        return 'MEDICAL CAMP';
      default:
        return 'OTHER';
    }
  }

  String get subCategoryString {
     switch (category) {
      case EventCategory.educational:
        return 'Educational';
      case EventCategory.medicalCamp:
        return 'Medical camp';
      default:
        return 'Other';
    }
  }

  Color get bgColor {
    switch (category) {
      case EventCategory.educational:
        return const Color(0xFFF1F6FC);
      case EventCategory.medicalCamp:
        return const Color(0xFFE8F6F0);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get stripeColor {
    switch (category) {
      case EventCategory.educational:
        return const Color(0xFFDFEDF9);
      case EventCategory.medicalCamp:
        return const Color(0xFFD4EFE1);
      default:
        return const Color(0xFFE5E7EB);
    }
  }
}
