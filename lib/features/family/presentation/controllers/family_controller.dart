import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
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

    if (state != null) {
      isDistrictsLoading.value = true;
      try {
        await Future.wait([
          loadAreas(),
          _repository.getDistricts(state.id).then((results) => districts.assignAll(results))
        ]);
      } catch (e) {
        AppLogger.e('Failed to load districts', e);
      } finally {
        isDistrictsLoading.value = false;
      }
    } else {
      await loadAreas();
    }
  }

  Future<void> onDistrictChanged(DropdownItem? district) async {
    selectedDistrict.value = district;
    selectedTaluka.value = null;
    talukas.clear();

    if (district != null) {
      isTalukasLoading.value = true;
      try {
        await Future.wait([
          loadAreas(),
          _repository.getTalukas(district.id).then((results) => talukas.assignAll(results))
        ]);
      } catch (e) {
        AppLogger.e('Failed to load talukas', e);
      } finally {
        isTalukasLoading.value = false;
      }
    } else {
      await loadAreas();
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

  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;
  int _currentLoadRequestId = 0;

  final RxString memberSearchQuery = ''.obs;
  final RxList<Family> filteredFamilies = <Family>[].obs;

  @override
  void onInit() {
    super.onInit();
    debounce(memberSearchQuery, (_) => _filterFamilies(), time: const Duration(milliseconds: 300));
  }

  void _filterFamilies() {
    if (memberSearchQuery.value.isEmpty) {
      filteredFamilies.assignAll(families);
      return;
    }
    
    final query = memberSearchQuery.value.toLowerCase();
    final results = families.map((family) {
      final matchingMembers = family.members.where((member) {
        final name = member.name.toLowerCase();
        final mobile = member.mobileNo?.toLowerCase() ?? '';
        final memberId = member.id.toLowerCase();
        return name.contains(query) || mobile.contains(query) || memberId.contains(query);
      }).toList();
      
      if (matchingMembers.isEmpty) return null;
      return Family(familyName: family.familyName, members: matchingMembers);
    }).whereType<Family>().toList();
    
    filteredFamilies.assignAll(results);
  }

  Future<void> loadAreas() async {
    _currentPage = 1;
    hasMore.value = true;
    state.value = AppState.loading;
    areas.clear();
    await _fetchAreas(isRefresh: true);
  }

  Future<void> loadNextPage() async {
    if (!hasMore.value || isNextPageLoading.value) return;
    isNextPageLoading.value = true;
    await _fetchAreas(isRefresh: false);
  }

  Future<void> _fetchAreas({required bool isRefresh}) async {
    final requestId = ++_currentLoadRequestId;

    try {
      final results = await _repository.getFamilyAreas(
        stateId: selectedState.value?.id ?? 0,
        districtId: selectedDistrict.value?.id ?? 0,
        talukaId: selectedTaluka.value?.id ?? 0,
        pageNo: _currentPage,
        pageSize: _pageSize,
      );

      if (requestId != _currentLoadRequestId) return;
      if (isRefresh) {
        areas.clear();
      }

      if (results.isEmpty) {
        hasMore.value = false;

        if (areas.isEmpty) {
          state.value = AppState.empty;
      } else {
          state.value = AppState.data;
        }

        return;
      }

      if (isRefresh) {
        areas.assignAll(List.unmodifiable(results));
      } else {
        areas.assignAll(List.unmodifiable([...areas, ...results]));
      }

      _currentPage++;

      if (results.length < _pageSize) {
        hasMore.value = false;
      }

      state.value = AppState.data;
    } catch (e, stack) {
      if (requestId != _currentLoadRequestId) return;
      AppLogger.e('Failed to load family areas', e, stack);
      if (isRefresh) {
        state.value = AppState.error;
      }
    } finally {
      if (requestId == _currentLoadRequestId) {
        isNextPageLoading.value = false;
      }
    }
  }

  Future<void> loadFamilies(int areaId) async {
    familyListState.value = AppState.loading;
    try {
      final results = await _repository.getFamiliesByArea(areaId);
      families.assignAll(results);
      _filterFamilies(); // Apply initial filter
      familyListState.value = filteredFamilies.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load families for areaId: $areaId', e, stack);
      familyListState.value = AppState.error;
    }
  }

  Future<void> resetFilters() async {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();
    await loadAreas();
  }

  String getFormattedDateOfBirth(Member member) {
    if (member.dateOfBirth == null) return LK.na;
    try {
      final dob = DateTime.parse(member.dateOfBirth!);
      return '${dob.year}/${dob.month.toString().padLeft(2, '0')}/${dob.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return member.dateOfBirth!.split('T')[0].replaceAll('-', '/');
    }
  }
}
