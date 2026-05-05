import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

class MarriageController extends GetxController {
  final Rx<AppState> state = AppState.data.obs;
  
  // Filter Observables
  final RxBool lookingForMarriage = true.obs;
  final RxString selectedGender = 'All'.obs;
  final RxBool isAdvancedFiltersOpen = false.obs;
  final RxBool excludeSameGotra = false.obs;
  
  final RxString selectedAgeFrom = '18'.obs;
  final RxString selectedAgeTo = '60'.obs;
  final RxString selectedHeightFrom = '4.5 ft'.obs;
  final RxString selectedHeightTo = '6.5 ft'.obs;
  final RxString selectedGotra = 'Any'.obs;
  final RxString selectedMaritalStatus = 'All'.obs;
  final RxString selectedState = 'All'.obs;
  final RxString selectedDistrict = 'All'.obs;
  final RxString selectedTaluka = 'All'.obs;
  final RxString selectedEducation = 'Any'.obs;
  final RxString selectedOccupation = 'Any'.obs;
  final RxString selectedIncomeFrom = 'Any'.obs;
  final RxString selectedIncomeTo = 'Any'.obs;
  
  final RxString searchQuery = ''.obs;

  static final List<Map<String, dynamic>> allMembers = [
    {
      'name': 'Rajesh Patel',
      'age': '28 yrs',
      'occupation': 'Engineer',
      'gotra': 'Kashyap Gotra',
      'location': 'Ahmedabad, Daskroi, Satellite',
      'lookingForMarriage': true,
      'gender': 'Male',
      'avatarColor': Color(0xFFBBDEFB),
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
      'avatarColor': Color(0xFFF8BBD0),
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
      'avatarColor': Color(0xFFBBDEFB),
      'avatarIconColor': Colors.blue,
    },
  ];

  final RxList<Map<String, dynamic>> filteredMembers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    applyFilters();
  }

  void applyFilters() {
    var results = allMembers.where((m) {
      // Basic Filters
      if (lookingForMarriage.value && !m['lookingForMarriage']) return false;
      if (selectedGender.value != 'All' && m['gender'] != selectedGender.value) return false;
      
      // Search Filter
      if (searchQuery.value.isNotEmpty) {
        final name = (m['name'] as String).toLowerCase();
        if (!name.contains(searchQuery.value.toLowerCase())) return false;
      }
      
      // Advanced filters (omitted for brevity in mock, but structure is here)
      return true;
    }).toList();
    
    filteredMembers.assignAll(results);
    state.value = results.isEmpty ? AppState.empty : AppState.data;
  }

  void toggleAdvancedFilters() {
    isAdvancedFiltersOpen.value = !isAdvancedFiltersOpen.value;
  }

  void clearFilters() {
    selectedGender.value = 'All';
    lookingForMarriage.value = true;
    searchQuery.value = '';
    // Reset all other filters...
    applyFilters();
  }
}
