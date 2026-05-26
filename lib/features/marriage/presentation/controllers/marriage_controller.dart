import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/unmarried_count.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';

import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/marriage/utils/marriage_filter_applicator.dart';

class MarriageController extends GetxController {
  MarriageController(
    this._repository,
    this._memberRepository,
    this._familyRepository,
  );

  final MarriageRepository _repository;
  final MemberRepository _memberRepository;
  final FamilyRepository _familyRepository;

  Timer? _debounceTimer;

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<UnmarriedCount> unmarriedCounts = <UnmarriedCount>[].obs;
  final RxBool lookingForMarriage = true.obs;
  final RxString selectedGender = 'All'.obs;
  final RxBool isAdvancedFiltersOpen = false.obs;
  final RxBool excludeSameGotra = false.obs;

  final RxString selectedAgeFrom = '18'.obs;
  final RxString selectedAgeTo = '60'.obs;
  final RxString selectedHeightFrom = '120 cm'.obs;
  final RxString selectedHeightTo = '210 cm'.obs;
  final RxString selectedGotra = 'Any'.obs;
  final RxString selectedMaritalStatus = 'All'.obs;
  final RxString selectedState = 'All'.obs;
  final RxString selectedDistrict = 'All'.obs;
  final RxString selectedTaluka = 'All'.obs;
  final RxString selectedArea = 'All'.obs;
  final RxString selectedEducation = 'Any'.obs;
  final RxString selectedOccupation = 'Any'.obs;
  final RxString selectedIncomeFrom = 'Any'.obs;
  final RxString selectedIncomeTo = 'Any'.obs;

  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final List<String> ages = List.generate(43, (i) => (18 + i).toString());
  final List<String> heights = List.generate(121, (i) => '${(120 + i)} cm');
  final List<String> maritalStatuses = [
    'All',
    'Unmarried',
    'Married',
    'Widow',
    'Widower',
    'Divorced',
  ];
  final List<String> incomeRanges = [
    'Any',
    '1-2 Lakh',
    '2-5 Lakh',
    '5-10 Lakh',
    '10+ Lakh',
  ];
  final RxList<String> dynamicGotras = <String>['Any'].obs;
  final RxList<String> dynamicOccupations = <String>['Any'].obs;
  final RxList<String> dynamicEducations = <String>['Any'].obs;
  final RxList<String> dynamicAreas = <String>['All'].obs;

  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;

  final RxList<Member> filteredMembers = <Member>[].obs;

  int get unmarriedMaleCount =>
      unmarriedCounts.firstWhereOrNull((e) => e.genderId == 1)?.count ?? 0;

  int get unmarriedFemaleCount =>
      unmarriedCounts.firstWhereOrNull((e) => e.genderId == 6)?.count ?? 0;

  @override
  void onInit() {
    super.onInit();
    final List<RxInterface<dynamic>> filterObservables = [
      searchQuery,
      selectedGender,
      lookingForMarriage,
      selectedAgeFrom,
      selectedAgeTo,
      selectedHeightFrom,
      selectedHeightTo,
      selectedGotra,
      selectedMaritalStatus,
      selectedState,
      selectedDistrict,
      selectedTaluka,
      selectedArea,
      selectedEducation,
      selectedOccupation,
      selectedIncomeFrom,
      selectedIncomeTo,
      excludeSameGotra,
    ];

    everAll(filterObservables, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 300), () => applyFilters());
    });
    loadProfiles();

    loadLocations();
    loadAllDropdowns();
  }

  Future<void> loadLocations() async {
    try {
      final s = await _familyRepository.getStates();
      states.assignAll(s);
    } catch (e) {
      AppLogger.e('Failed to load states', e);
    }
  }

  Future<void> onStateChanged(String stateName) async {
    selectedState.value = stateName;
    selectedDistrict.value = 'All';
    selectedTaluka.value = 'All';
    districts.clear();
    talukas.clear();

    if (stateName == 'All') {
      return;
    }

    final stateId = states.firstWhereOrNull((s) => s.text == stateName)?.id;
    if (stateId != null) {
      final d = await _familyRepository.getDistricts(stateId);
      districts.assignAll(d);
    }
  }

  Future<void> onDistrictChanged(String districtName) async {
    selectedDistrict.value = districtName;
    selectedTaluka.value = 'All';
    talukas.clear();

    if (districtName == 'All') {
      return;
    }

    final districtId = districts
        .firstWhereOrNull((d) => d.text == districtName)
        ?.id;
    if (districtId != null) {
      final t = await _familyRepository.getTalukas(districtId);
      talukas.assignAll(t);
    }
  }

  Future<void> loadProfiles({bool showLoading = true}) async {
    if (showLoading) state.value = AppState.loading;
    try {
      int? genderId;
      if (selectedGender.value == 'Male') {
        genderId = 1;
      } else if (selectedGender.value == 'Female') {
        genderId = 6;
      }

      final results = await Future.wait([
        _memberRepository.searchMembers(
          query: searchQuery.value,
          genderId: genderId,
          lookingForMarriage: lookingForMarriage.value,
        ),
        _repository.getUnmarriedCounts(),
      ]);

      final memberResult = results[0] as Result<PaginatedResponse<Member>>;
      List<Member> members = memberResult.dataOrNull?.data ?? [];
      _updateDynamicLists(members);
      
      String? myGotra;
      if (excludeSameGotra.value) {
        try {
          final profileController = Get.find<ProfileFormController>();
          myGotra = profileController.gotra.value;
        } catch (_) {}
      }

      final filterState = MarriageFilterState(
        searchQuery: searchQuery.value,
        selectedAgeFrom: selectedAgeFrom.value,
        selectedAgeTo: selectedAgeTo.value,
        selectedHeightFrom: selectedHeightFrom.value,
        selectedHeightTo: selectedHeightTo.value,
        selectedGotra: selectedGotra.value,
        selectedMaritalStatus: selectedMaritalStatus.value,
        selectedState: selectedState.value,
        selectedDistrict: selectedDistrict.value,
        selectedTaluka: selectedTaluka.value,
        selectedArea: selectedArea.value,
        selectedEducation: selectedEducation.value,
        selectedOccupation: selectedOccupation.value,
        excludeSameGotra: excludeSameGotra.value,
        myGotra: myGotra,
      );

      final filtered = MarriageFilterApplicator.apply(members, filterState);
      filteredMembers.assignAll(filtered);
      unmarriedCounts.assignAll(results[1] as List<UnmarriedCount>);
      state.value = filteredMembers.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load marriage profiles', e, stack);
      state.value = AppState.error;
    }
  }

  void applyFilters() {
    loadProfiles(showLoading: false);
  }

  void toggleAdvancedFilters() {
    isAdvancedFiltersOpen.value = !isAdvancedFiltersOpen.value;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedAgeFrom.value = '18';
    selectedAgeTo.value = '60';
    selectedHeightFrom.value = '120 cm';
    selectedHeightTo.value = '210 cm';
    selectedGotra.value = 'Any';
    selectedMaritalStatus.value = 'All';
    selectedState.value = 'All';
    selectedDistrict.value = 'All';
    selectedTaluka.value = 'All';
    selectedArea.value = 'All';
    selectedEducation.value = 'Any';
    selectedOccupation.value = 'Any';
    selectedIncomeFrom.value = 'Any';
    selectedIncomeTo.value = 'Any';
    excludeSameGotra.value = false;
  }

  void _updateDynamicLists(List<Member> members) {
    final gotras = members
        .map((m) => m.gotra.trim())
        .where((g) => g.isNotEmpty)
        .map((g) => g[0].toUpperCase() + g.substring(1).toLowerCase())
        .toSet()
        .toList();
    gotras.sort();
    dynamicGotras.assignAll(['Any', ...gotras]);
    final areas = members
        .map((m) => m.area.trim())
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList();
    areas.sort();
    dynamicAreas.assignAll(['All', ...areas]);
  }

  Future<void> loadAllDropdowns() async {
    await Future.wait([
      _fetchDropdown(
        '/EducationalQualification/list/dropdown',
        dynamicEducations,
        ['Secondary', 'Higher Secondary', 'Graduate', 'Post Graduate', 'PHD'],
      ),
      _fetchDropdown('/Occupation/dropdown', dynamicOccupations, [
        'Private Employee',
        'Government Employee',
        'Business Owner',
        'Farmer',
        'Housewife',
        'Student',
        'Retired',
        'Unemployed',
        'Other',
      ]),
    ]);
  }

  Future<void> _fetchDropdown(
    String path,
    RxList<String> targetList,
    List<String> fallbacks,
  ) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1$path');
      if (response.data != null) {
        final json = response.data as Map<String, dynamic>;
        if (json['succeeded'] == true) {
          final rawData = json['data'];
          List<dynamic> list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map<String, dynamic>) {
            list =
                (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ??
                [];
          }
          final items = list
              .map((e) {
                final map = e as Map<String, dynamic>;
                final textKeys = [
                  'text',
                  'Text',
                  'name',
                  'Name',
                  'value',
                  'Value',
                ];
                for (final key in textKeys) {
                  if (map.containsKey(key) && map[key] != null) {
                    return map[key].toString().trim();
                  }
                }
                for (final entry in map.entries) {
                  if (!entry.key.toLowerCase().contains('id')) {
                    return entry.value.toString().trim();
                  }
                }
                return '';
              })
              .where((s) => s.isNotEmpty)
              .toList();

          if (items.isNotEmpty) {
            targetList.assignAll(['Any', ...items]);
            return;
          }
        }
      }
      targetList.assignAll(['Any', ...fallbacks]);
    } catch (e) {
      AppLogger.e('Failed to fetch dropdown $path', e);
      targetList.assignAll(['Any', ...fallbacks]);
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }
}
