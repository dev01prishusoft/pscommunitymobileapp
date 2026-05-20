import 'package:get/get.dart';
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

class MarriageController extends GetxController {
  MarriageController(this._repository, this._memberRepository, this._familyRepository);

  final MarriageRepository _repository;
  final MemberRepository _memberRepository;
  final FamilyRepository _familyRepository;

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<UnmarriedCount> unmarriedCounts = <UnmarriedCount>[].obs;
  
  // Filter Observables
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
  
  final RxString searchQuery = ''.obs;
  
  // Dynamic Lists
  final RxList<String> dynamicGotras = <String>['Any'].obs;
  final RxList<String> dynamicOccupations = <String>['Any'].obs;
  final RxList<String> dynamicEducations = <String>['Any'].obs;
  final RxList<String> dynamicAreas = <String>['All'].obs;
  
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;

  final RxList<Member> filteredMembers = <Member>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search and filter changes to avoid excessive API calls
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

    for (var obs in filterObservables) {
      debounce(obs, (_) => applyFilters(), time: const Duration(milliseconds: 300));
    }
    
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
    
    final districtId = districts.firstWhereOrNull((d) => d.text == districtName)?.id;
    if (districtId != null) {
      final t = await _familyRepository.getTalukas(districtId);
      talukas.assignAll(t);
    }
  }

  Future<void> loadProfiles({bool showLoading = true}) async {
    if (showLoading) state.value = AppState.loading;
    try {
      int? genderId;
      if (selectedGender.value == 'Male') genderId = 1;
      else if (selectedGender.value == 'Female') genderId = 6;

      final results = await Future.wait([
        _memberRepository.searchMembers(
          query: searchQuery.value,
          genderId: genderId,
          lookingForMarriage: lookingForMarriage.value,
        ),
        _repository.getUnmarriedCounts(),
      ]);
      
      List<Member> members = results[0] as List<Member>;

      // Local Search Filter (Issue 13)
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        members = members.where((m) {
          final fullName = m.fullName.toLowerCase();
          final occupation = m.occupation.toLowerCase();
          final age = m.age.toString();
          final memberNo = (m.memberNo ?? '').toLowerCase();
          final mobile = (m.mobileNo ?? '').toLowerCase();

          return fullName.contains(query) ||
              occupation.contains(query) ||
              age.contains(query) ||
              memberNo.contains(query) ||
              mobile.contains(query);
        }).toList();
      }

      // Gotras are extracted from active members to show relevant Gotras
      final gotras = members
          .map((m) => m.gotra.trim())
          .where((g) => g.isNotEmpty)
          .map((g) => g[0].toUpperCase() + g.substring(1).toLowerCase())
          .toSet()
          .toList()
        ..sort();
      dynamicGotras.assignAll(['Any', ...gotras]);

      // Areas are extracted dynamically from active members
      final areas = members
          .map((m) => m.area.trim())
          .where((a) => a.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      dynamicAreas.assignAll(['All', ...areas]);

      // Populate locations from members (Issue 11)
      final memStates = members.map((m) => m.occupationStateName).whereType<String>().toSet().toList()..sort();
      if (memStates.isNotEmpty) {
        // We can either update the 'states' dropdown or use a separate dynamic list
        // For simplicity and consistency with Gotra/Occupation, let's ensure the dropdown matches
      }

      // Apply Local Advanced Filters
      if (selectedAgeFrom.value != '18' || selectedAgeTo.value != '60') {
        final minAge = int.tryParse(selectedAgeFrom.value) ?? 18;
        final maxAge = int.tryParse(selectedAgeTo.value) ?? 60;
        members = members.where((m) => m.age >= minAge && m.age <= maxAge).toList();
      }
      
      // Height Filter (Issue 8 - converted to CM)
      if (selectedHeightFrom.value != '120 cm' || selectedHeightTo.value != '210 cm') {
        final minH = int.tryParse(selectedHeightFrom.value.replaceAll(' cm', '')) ?? 120;
        final maxH = int.tryParse(selectedHeightTo.value.replaceAll(' cm', '')) ?? 210;
        members = members.where((m) {
          final h = m.height ?? 0;
          return h >= minH && h <= maxH;
        }).toList();
      }

      if (selectedGotra.value != 'Any') {
        members = members.where((m) {
          final mGotra = m.gotra.trim();
          if (mGotra.isEmpty) return false;
          final normalized = mGotra[0].toUpperCase() + mGotra.substring(1).toLowerCase();
          return normalized == selectedGotra.value;
        }).toList();
      }
      
      if (excludeSameGotra.value) {
        try {
          final profileController = Get.find<ProfileFormController>();
          final myGotra = profileController.gotra.value;
          if (myGotra.isNotEmpty) {
            members = members.where((m) => m.gotra != myGotra).toList();
          }
        } catch (_) {}
      }

      if (selectedMaritalStatus.value != 'All') {
        members = members.where((m) => (m.maritalStatusName ?? '') == selectedMaritalStatus.value).toList();
      }
      
      if (selectedState.value != 'All') {
        members = members.where((m) => (m.occupationStateName ?? '') == selectedState.value).toList();
      }
      
      if (selectedDistrict.value != 'All') {
        members = members.where((m) => (m.occupationDistrictName ?? '') == selectedDistrict.value).toList();
      }
      
      if (selectedTaluka.value != 'All') {
        members = members.where((m) => (m.occupationTalukaName ?? '') == selectedTaluka.value).toList();
      }
      
      if (selectedArea.value != 'All') {
        members = members.where((m) => m.area == selectedArea.value).toList();
      }

      if (selectedEducation.value != 'Any') {
        members = members.where((m) => (m.jobPositionName ?? '').contains(selectedEducation.value)).toList();
      }

      if (selectedOccupation.value != 'Any') {
        members = members.where((m) => 
          (m.occupationName ?? '') == selectedOccupation.value ||
          (m.occupationTypeName ?? '') == selectedOccupation.value
        ).toList();
      }

      if (selectedIncomeFrom.value != 'Any' || selectedIncomeTo.value != 'Any') {
        // Income filtering (simplified for the predefined ranges)
        members = members.where((m) {
          return true; // Placeholder for complex range matching
        }).toList();
      }

      filteredMembers.assignAll(members);
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
    // Preserve main toggles: selectedGender and lookingForMarriage
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
    applyFilters();
  }

  void _updateDynamicLists(List<Member> members) {
    // Collect all unique gotras
    final gotras = members
        .map((m) => m.gotra.trim())
        .where((g) => g.isNotEmpty)
        .map((g) => g[0].toUpperCase() + g.substring(1).toLowerCase())
        .toSet()
        .toList();
    gotras.sort();
    dynamicGotras.assignAll(['Any', ...gotras]);

    // Collect all unique areas
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
      _fetchDropdown('/EducationalQualification/list/dropdown', dynamicEducations, ['Secondary', 'Higher Secondary', 'Graduate', 'Post Graduate', 'PHD']),
      _fetchDropdown('/Occupation/dropdown', dynamicOccupations, ['Private Employee', 'Government Employee', 'Business Owner', 'Farmer', 'Housewife', 'Student', 'Retired', 'Unemployed', 'Other']),
    ]);
  }

  Future<void> _fetchDropdown(String path, RxList<String> targetList, List<String> fallbacks) async {
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
            list = (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ?? [];
          }
          final items = list.map((e) {
            final map = e as Map<String, dynamic>;
            final textKeys = ['text', 'Text', 'name', 'Name', 'value', 'Value'];
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
          }).where((s) => s.isNotEmpty).toList();
          
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
}
