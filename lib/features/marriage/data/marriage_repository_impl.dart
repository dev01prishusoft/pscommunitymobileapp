import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  final ApiClient _apiClient;

  MarriageRepositoryImpl(this._apiClient);

  @override
  Future<List<Map<String, dynamic>>> getMatrimonialProfiles() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      {
        'name': 'Rajesh Patel',
        'age': '28 yrs',
        'occupation': 'Engineer',
        'gotra': 'Kashyap Gotra',
        'location': 'Ahmedabad, Daskroi, Satellite',
        'lookingForMarriage': true,
        'gender': 'Male',
        'avatarColor': const Color(0xFFBBDEFB),
        'avatarIconColor': Colors.blue,
      },
      {
        'name': 'Priya Shah',
        'age': '26 yrs',
        'occupation': 'Doctor',
        'gotra': 'Bharadwaj Gotra',
        'location': 'Ahmedabad, Daskroi, Naranpura',
        'lookingForMarriage': true,
        'gender': 'Female',
        'avatarColor': const Color(0xFFF8BBD0),
        'avatarIconColor': Colors.pink,
      },
      {
        'name': 'Amit Mehta',
        'age': '32 yrs',
        'occupation': 'Business',
        'gotra': 'Vashishtha Gotra',
        'location': 'Gandhinagar, City, Sector 21',
        'lookingForMarriage': false,
        'gender': 'Male',
        'avatarColor': const Color(0xFFBBDEFB),
        'avatarIconColor': Colors.blue,
      },
    ];
  }
}
