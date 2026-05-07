import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member_address.dart';

class FamilyController extends GetxController {

  FamilyController(this._repository);
  final FamilyRepository _repository;

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<FamilyArea> areas = <FamilyArea>[].obs;
  final RxList<Family> families = <Family>[].obs;
  
  final Rx<AppState> familyListState = AppState.loading.obs;
  final Rx<AppState> memberDetailState = AppState.loading.obs;
  final Rxn<Member> selectedMember = Rxn<Member>();
  final RxList<MemberAddress> memberAddresses = <MemberAddress>[].obs;
  
  final RxBool filtersExpanded = true.obs;
  
  // Loading States
  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isTalukasLoading = false.obs;

  // Dropdown Lists
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;

  // Selected Values
  final Rxn<DropdownItem> selectedState = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedDistrict = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedTaluka = Rxn<DropdownItem>();

  Future<void> loadMemberDetails(int memberId) async {
    memberDetailState.value = AppState.loading;
    try {
      final detailFuture = _repository.getMemberDetails(memberId);
      final addressFuture = _repository.getMemberAddresses(memberId);

      final results = await Future.wait([detailFuture, addressFuture]);

      selectedMember.value = results[0] as Member;
      memberAddresses.assignAll(results[1] as List<MemberAddress>);

      memberDetailState.value = AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load member details for ID: $memberId', e, stack);
      memberDetailState.value = AppState.error;
    }
  }

  Future<void> loadStates() async {
    isStatesLoading.value = true;
    try {
      final results = await _repository.getStates();
      states.assignAll(results);
    } catch (e) {
      AppLogger.e('Failed to load states', e);
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<void> onStateChanged(DropdownItem? state) async {
    selectedState.value = state;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();

    // Refresh list with new filter
    loadAreas();

    if (state != null) {
      isDistrictsLoading.value = true;
      try {
        final results = await _repository.getDistricts(state.id);
        districts.assignAll(results);
      } catch (e) {
        AppLogger.e('Failed to load districts', e);
      } finally {
        isDistrictsLoading.value = false;
      }
    }
  }

  Future<void> onDistrictChanged(DropdownItem? district) async {
    selectedDistrict.value = district;
    selectedTaluka.value = null;
    talukas.clear();

    // Refresh list with new filter
    loadAreas();

    if (district != null) {
      isTalukasLoading.value = true;
      try {
        final results = await _repository.getTalukas(district.id);
        talukas.assignAll(results);
      } catch (e) {
        AppLogger.e('Failed to load talukas', e);
      } finally {
        isTalukasLoading.value = false;
      }
    }
  }

  void onTalukaChanged(DropdownItem? taluka) {
    selectedTaluka.value = taluka;
    // Refresh list with new filter
    loadAreas();
  }

  void searchAreas() {
    loadAreas();
  }

  Future<void> loadAreas() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getFamilyAreas(
        stateId: selectedState.value?.id ?? 0,
        districtId: selectedDistrict.value?.id ?? 0,
        talukaId: selectedTaluka.value?.id ?? 0,
      );
      areas.assignAll(results);
      // Set to data so it shows the custom _EmptyState if areas is empty
      state.value = AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load family areas', e, stack);
      
      // Clear areas so it shows the empty state
      areas.clear();
      // Set to data state as requested to use the custom _EmptyState layout
      state.value = AppState.data;
    }
  }

  Future<void> loadFamilies(int areaId) async {
    familyListState.value = AppState.loading;
    try {
      final results = await _repository.getFamiliesByArea(areaId);
      families.assignAll(results);
      familyListState.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load families for areaId: $areaId', e, stack);
      familyListState.value = AppState.error;
    }
  }

  List<FamilyArea> get filteredAreas => areas;

  void resetFilters() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();
    loadAreas();
  }
}
