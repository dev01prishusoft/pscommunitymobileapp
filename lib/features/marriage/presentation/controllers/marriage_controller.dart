import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/marriage_profile.dart';

class MarriageController extends GetxController {
  final MarriageRepository _repository;

  MarriageController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  
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

  final RxList<MarriageProfile> allMembers = <MarriageProfile>[].obs;
  final RxList<MarriageProfile> filteredMembers = <MarriageProfile>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    state.value = AppState.loading;
    try {
      final profiles = await _repository.getMatrimonialProfiles();
      allMembers.assignAll(profiles);
      applyFilters();
    } catch (e, stack) {
      AppLogger.e('Failed to load matrimonial profiles', e, stack);
      state.value = AppState.error;
    }
  }

  void applyFilters() {
    final results = allMembers.where((m) {
      // Basic Filters
      if (lookingForMarriage.value && !m.lookingForMarriage) return false;
      
      if (selectedGender.value != 'All' && m.gender != selectedGender.value) return false;
      
      // Search Filter
      if (searchQuery.value.isNotEmpty) {
        final name = m.name.toLowerCase();
        if (!name.contains(searchQuery.value.toLowerCase())) return false;
      }
      
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
    applyFilters();
  }
}
