import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  BusinessRepositoryImpl(this._apiClient);

  @override
  Future<List<BusinessCategory>> getCategories() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 350));
    
    return const [
      BusinessCategory(title: 'Automobile', icon: Icons.directions_car_rounded),
      BusinessCategory(title: 'Other', icon: Icons.more_horiz_rounded),
      BusinessCategory(title: 'Furniture', icon: Icons.chair_rounded),
      BusinessCategory(title: 'Education / Training', icon: Icons.school_rounded),
      BusinessCategory(title: 'Health / Medical', icon: Icons.local_hospital_rounded),
      BusinessCategory(title: 'Electronics / Electrician', icon: Icons.electrical_services_rounded),
      BusinessCategory(title: 'Tailor / Garments', icon: Icons.dry_cleaning_rounded),
      BusinessCategory(title: 'Beauty / Cosmetics', icon: Icons.face_retouching_natural_rounded),
    ];
  }
}
