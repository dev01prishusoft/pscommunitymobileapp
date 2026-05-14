import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/unmarried_count.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';

class MarriageController extends GetxController {
  final MarriageRepository _repository;
  final MemberRepository _memberRepository;

  MarriageController(this._repository, this._memberRepository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<UnmarriedCount> unmarriedCounts = <UnmarriedCount>[].obs;
  
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
  final RxString selectedArea = 'All'.obs;
  final RxString selectedEducation = 'Any'.obs;
  final RxString selectedOccupation = 'Any'.obs;
  final RxString selectedIncomeFrom = 'Any'.obs;
  final RxString selectedIncomeTo = 'Any'.obs;
  
  final RxString searchQuery = ''.obs;

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

      // Apply Local Advanced Filters
      if (selectedAgeFrom.value != '18' || selectedAgeTo.value != '60') {
        final minAge = int.tryParse(selectedAgeFrom.value) ?? 18;
        final maxAge = int.tryParse(selectedAgeTo.value) ?? 60;
        members = members
            .where((m) => m.age >= minAge && m.age <= maxAge)
            .toList();
      }
      if (selectedGotra.value != 'Any') {
        members = members.where((m) => m.gotra == selectedGotra.value).toList();
      }
      if (selectedMaritalStatus.value != 'All') {
        members = members
            .where(
              (m) => (m.maritalStatusName ?? '') == selectedMaritalStatus.value,
            )
            .toList();
      }
      if (selectedState.value != 'All') {
        members = members
            .where((m) => (m.occupationStateName ?? '') == selectedState.value)
            .toList();
      }
      if (selectedDistrict.value != 'All') {
        members = members
            .where(
              (m) => (m.occupationDistrictName ?? '') == selectedDistrict.value,
            )
            .toList();
      }
      if (selectedTaluka.value != 'All') {
        members = members
            .where(
              (m) => (m.occupationTalukaName ?? '') == selectedTaluka.value,
            )
            .toList();
      }
      if (selectedArea.value != 'All') {
        members = members.where((m) => m.area == selectedArea.value).toList();
      }
      if (selectedOccupation.value != 'Any') {
        members = members
            .where(
              (m) =>
                  (m.occupationName ?? '') == selectedOccupation.value ||
                  (m.occupationTypeName ?? '') == selectedOccupation.value,
            )
            .toList();
      }

      filteredMembers.assignAll(members);
      unmarriedCounts.assignAll(results[1] as List<UnmarriedCount>);
      
      state.value = filteredMembers.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load matrimonial data', e, stack);
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
    selectedGender.value = 'All';
    lookingForMarriage.value = true;
    searchQuery.value = '';
    // Reset advanced filters too
    selectedAgeFrom.value = '18';
    selectedAgeTo.value = '60';
    selectedHeightFrom.value = '4.5 ft';
    selectedHeightTo.value = '6.5 ft';
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
    loadProfiles();
  }
}
