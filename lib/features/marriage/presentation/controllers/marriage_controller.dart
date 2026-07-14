import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/unmarried_count.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/features/marriage/utils/marriage_filter_applicator.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';

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
  final RxBool isSearchVisible = false.obs;
  String? _myGotra;

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
  final RxString selectedIncomeFrom = ''.obs;
  final RxString selectedIncomeTo = ''.obs;

  final TextEditingController incomeFromCtrl = TextEditingController();
  final TextEditingController incomeToCtrl = TextEditingController();
  final RxString incomeError = ''.obs;
  final RxString ageError = ''.obs;
  final RxString heightError = ''.obs;

  final TextEditingController searchTextController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxString searchQuery = ''.obs;
  final List<String> ages = List.generate(43, (i) => (18 + i).toString());
  final List<String> heights = List.generate(121, (i) => '${(120 + i)} cm');
  final RxList<String> dynamicMaritalStatuses = <String>['All'].obs;
  final Map<String, int> maritalStatusIdMap = {};

  final RxList<String> dynamicGotras = <String>['Any'].obs;
  final RxList<String> dynamicOccupations = <String>['Any'].obs;
  final RxList<String> dynamicEducations = <String>['Any'].obs;

  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;
  final RxList<DropdownItem> areas = <DropdownItem>[].obs;

  final RxList<Member> filteredMembers = <Member>[].obs;
  final List<Member> _allMembers = [];

  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;
  int _currentLoadRequestId = 0;

  int get unmarriedMaleCount =>
      unmarriedCounts.firstWhereOrNull((e) => e.genderId == 1)?.count ?? 0;

  int get unmarriedFemaleCount =>
      unmarriedCounts.firstWhereOrNull((e) => e.genderId == 6)?.count ?? 0;

  @override
  void onInit() {
    super.onInit();
    final List<RxInterface<dynamic>> filterObservables = [
      searchQuery,
      lookingForMarriage,
      selectedGender,
      selectedAgeFrom,
      selectedAgeTo,
      selectedHeightFrom,
      selectedHeightTo,
      selectedGotra,
      excludeSameGotra,
      selectedMaritalStatus,
      selectedState,
      selectedDistrict,
      selectedTaluka,
      selectedArea,
      selectedEducation,
      selectedOccupation,
      selectedIncomeFrom,
      selectedIncomeTo,
    ];

    incomeFromCtrl.addListener(() {
      selectedIncomeFrom.value = incomeFromCtrl.text;
      _validateIncome();
    });

    incomeToCtrl.addListener(() {
      selectedIncomeTo.value = incomeToCtrl.text;
      _validateIncome();
    });

    everAll(filterObservables, (_) {
      _validateAge();
      _validateHeight();
      _validateIncome();
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 300), () {
        if (ageError.value.isEmpty &&
            heightError.value.isEmpty &&
            incomeError.value.isEmpty) {
          applyFilters();
        }
      });
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadNextPage();
      }
    });

    loadProfiles();
    loadLocations();
    loadAllDropdowns();
    _loadMyGotra();
  }

  void _validateIncome() {
    final min = int.tryParse(selectedIncomeFrom.value);
    final max = int.tryParse(selectedIncomeTo.value);
    if (min != null && max != null && min > max) {
      incomeError.value = LK.fromGreaterToError.tr;
    } else {
      incomeError.value = '';
    }
  }

  void _validateAge() {
    final fromVal = int.tryParse(selectedAgeFrom.value) ?? 0;
    final toVal = int.tryParse(selectedAgeTo.value) ?? 1000;
    if (fromVal > toVal) {
      ageError.value = LK.fromGreaterToError.tr;
    } else {
      ageError.value = '';
    }
  }

  void _validateHeight() {
    final fromVal =
        double.tryParse(selectedHeightFrom.value.replaceAll(' cm', '')) ?? 0;
    final toVal =
        double.tryParse(selectedHeightTo.value.replaceAll(' cm', '')) ?? 1000;
    if (fromVal > toVal) {
      heightError.value = LK.fromGreaterToError.tr;
    } else {
      heightError.value = '';
    }
  }

  Future<void> _loadMyGotra() async {
    try {
      if (Get.isRegistered<TokenManager>()) {
        final tokenManager = Get.find<TokenManager>();
        final memberId = tokenManager.memberId;
        if (memberId != null) {
          final member = await _familyRepository.getMemberDetails(memberId);
          _myGotra = member.gotra.trim();
          if (excludeSameGotra.value &&
              _myGotra != null &&
              _myGotra!.isNotEmpty) {
            applyFilters();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> loadLocations() async {
    try {
      final s = await _familyRepository.getStates();
      states.assignAll(s);
    } catch (_) {}
  }

  Future<void> onStateChanged(String stateName) async {
    selectedState.value = stateName;
    selectedDistrict.value = 'All';
    selectedTaluka.value = 'All';
    selectedArea.value = 'All';
    districts.clear();
    talukas.clear();
    areas.clear();

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
    selectedArea.value = 'All';
    talukas.clear();
    areas.clear();

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

  Future<void> onTalukaChanged(String talukaName) async {
    selectedTaluka.value = talukaName;
    selectedArea.value = 'All';
    areas.clear();

    if (talukaName == 'All') {
      return;
    }

    final talukaId = talukas.firstWhereOrNull((t) => t.text == talukaName)?.id;
    if (talukaId != null) {
      final a = await _familyRepository.getAreas(talukaId);
      areas.assignAll(a);
    }
  }

  Future<void> loadProfiles({
    bool showLoading = true,
    bool isRefresh = true,
  }) async {
    final requestId = ++_currentLoadRequestId;

    if (isRefresh) {
      _currentPage = 1;
      hasMore.value = true;
      if (showLoading) state.value = AppState.loading;
      _allMembers.clear();
    } else {
      if (!hasMore.value || isNextPageLoading.value) return;
      isNextPageLoading.value = true;
    }

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
          pageNumber: _currentPage,
          pageSize: _pageSize,
        ),
        if (isRefresh) _repository.getUnmarriedCounts(),
      ]);

      if (requestId != _currentLoadRequestId) return;

      final memberResult = results[0] as Result<PaginatedResponse<Member>>;
      final List<Member> newMembers = memberResult.dataOrNull?.data ?? [];
      if (newMembers.isEmpty) {
        hasMore.value = false;
        if (_allMembers.isEmpty) {
          state.value = AppState.empty;
        } else {
          state.value = AppState.data;
        }
        isNextPageLoading.value = false;
        return;
      }

      _allMembers.addAll(newMembers);

      _currentPage++;
      if (newMembers.length < _pageSize) {
        hasMore.value = false;
      }

      _updateDynamicLists(_allMembers);

      String? myGotra;
      if (excludeSameGotra.value && _myGotra != null && _myGotra!.isNotEmpty) {
        myGotra = _myGotra;
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
        selectedStateId: states
            .firstWhereOrNull((s) => s.text == selectedState.value)
            ?.id,
        selectedDistrictId: districts
            .firstWhereOrNull((d) => d.text == selectedDistrict.value)
            ?.id,
        selectedTalukaId: talukas
            .firstWhereOrNull((t) => t.text == selectedTaluka.value)
            ?.id,
        selectedEducation: selectedEducation.value,
        selectedOccupation: selectedOccupation.value,
        selectedIncomeFrom: selectedIncomeFrom.value,
        selectedIncomeTo: selectedIncomeTo.value,
        excludeSameGotra: excludeSameGotra.value,
        myGotra: myGotra,
      );

      final filtered = MarriageFilterApplicator.apply(_allMembers, filterState);
      filteredMembers.assignAll(filtered);

      if (isRefresh && results.length > 1) {
        unmarriedCounts.assignAll(results[1] as List<UnmarriedCount>);
      }

      state.value = filteredMembers.isEmpty ? AppState.empty : AppState.data;
    } catch (e) {
      if (requestId != _currentLoadRequestId) return;
      if (isRefresh) {
        state.value = AppState.error;
      }
    } finally {
      if (requestId == _currentLoadRequestId) {
        isNextPageLoading.value = false;
      }
    }
  }

  Future<void> loadNextPage() async {
    await loadProfiles(showLoading: false, isRefresh: false);
  }

  void applyFilters() {
    loadProfiles(showLoading: false, isRefresh: true);
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
    districts.clear();
    talukas.clear();
    areas.clear();
    selectedEducation.value = 'Any';
    selectedOccupation.value = 'Any';
    selectedIncomeFrom.value = '';
    selectedIncomeTo.value = '';
    incomeFromCtrl.clear();
    incomeToCtrl.clear();
    incomeError.value = '';
    ageError.value = '';
    heightError.value = '';
    excludeSameGotra.value = false;
  }

  void closeAdvancedFilters() {
    if (incomeError.value.isNotEmpty ||
        ageError.value.isNotEmpty ||
        heightError.value.isNotEmpty) {
      final errorMsg = [
        incomeError.value,
        ageError.value,
        heightError.value,
      ].where((e) => e.isNotEmpty).first;
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: errorMsg,
          isErrorMessage: true,
        ),
      ).show();
      return;
    }
    isAdvancedFiltersOpen.value = false;
  }

  void openAdvancedFilters() {
    isAdvancedFiltersOpen.value = true;
  }

  void _updateDynamicLists(List<Member> members) {}

  Future<void> loadAllDropdowns() async {
    final samajId = Get.find<TokenManager>().samajId;
    final gotraPath = samajId != null
        ? '/Gotra/dropdown?samajId=$samajId'
        : '/Gotra/dropdown';

    await Future.wait([
      _fetchDropdown(gotraPath, dynamicGotras, [], firstItem: 'Any'),
      _fetchDropdown(
        '/EducationalQualification/mobile/dropdown',
        dynamicEducations,
        ['Secondary', 'Higher Secondary', 'Graduate', 'Post Graduate', 'PHD'],
      ),
      _fetchDropdown('/Occupation/mobile/dropdown', dynamicOccupations, [
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
      _fetchDropdown(
        '/MaritalStatus/dropdown',
        dynamicMaritalStatuses,
        ['Unmarried', 'Married', 'Widow', 'Widower', 'Divorced'],
        firstItem: 'All',
        idMap: maritalStatusIdMap,
      ),
    ]);
  }

  Future<void> _fetchDropdown(
    String path,
    RxList<String> targetList,
    List<String> fallbacks, {
    String firstItem = 'Any',
    Map<String, int>? idMap,
    bool clearMap = true,
  }) async {
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
          if (idMap != null && clearMap) idMap.clear();
          final items = list
              .map((e) {
                final map = e as Map<String, dynamic>;
                String text = '';
                int? id;

                for (final key in [
                  'text',
                  'Text',
                  'name',
                  'Name',
                  'value',
                  'Value',
                ]) {
                  if (map.containsKey(key) && map[key] != null) {
                    text = map[key].toString().trim();
                    break;
                  }
                }

                if (text.isEmpty) {
                  for (final entry in map.entries) {
                    if (!entry.key.toLowerCase().contains('id')) {
                      text = entry.value.toString().trim();
                      break;
                    }
                  }
                }

                for (final entry in map.entries) {
                  if (entry.key.toLowerCase().contains('id')) {
                    id = int.tryParse(entry.value.toString());
                    break;
                  }
                }

                if (idMap != null && text.isNotEmpty && id != null) {
                  idMap[text] = id;
                }

                return text;
              })
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();

          if (items.isNotEmpty) {
            targetList.assignAll([firstItem, ...items]);
            return;
          }
        }
      }
      targetList.assignAll([firstItem, ...fallbacks]);
    } catch (e) {
      targetList.assignAll([firstItem, ...fallbacks]);
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    scrollController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }
}
