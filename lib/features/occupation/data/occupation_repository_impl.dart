import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class OccupationRepositoryImpl implements OccupationRepository {
  final ApiClient _apiClient;

  OccupationRepositoryImpl(this._apiClient);

  @override
  Future<List<OccupationItem>> getOccupations() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      OccupationItem(name: 'Engineer', count: 24, icon: Icons.engineering),
      OccupationItem(name: 'Doctor', count: 12, icon: Icons.local_hospital),
      OccupationItem(name: 'Teacher', count: 10, icon: Icons.school),
      OccupationItem(name: 'Trader', count: 8, icon: Icons.business_center),
      OccupationItem(name: 'Lawyer', count: 6, icon: Icons.gavel),
      OccupationItem(name: 'Business Owner', count: 5, icon: Icons.factory),
      OccupationItem(name: 'Accountant', count: 4, icon: Icons.analytics),
      OccupationItem(name: 'Architect', count: 3, icon: Icons.account_balance),
      OccupationItem(name: 'Software Dev', count: 7, icon: Icons.code),
    ];
  }
}
