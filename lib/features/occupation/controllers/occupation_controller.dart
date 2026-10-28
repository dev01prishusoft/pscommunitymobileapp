import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/core/models/occupation_item.dart';
import 'package:pscommunitymobileapp/features/family/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/occupation/repositories/occupation_repository.dart';

class OccupationController extends GetxController {
  OccupationController(this._repository, this._familyRepository);

  final OccupationRepository _repository;
  final FamilyRepository _familyRepository;

  final Rx<AppState> state = AppState.loading.obs;
  final Rx<AppState> detailsState = AppState.loading.obs;
  final RxList<OccupationItem> occupations = <OccupationItem>[].obs;
  final RxList<OccupationItem> filteredOccupations = <OccupationItem>[].obs;
  final RxList<DropdownItem> occupationTypes = <DropdownItem>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<DropdownItem> selectedOccupationType = Rxn<DropdownItem>();
  final RxList<String> selectedCategories = <String>[].obs;
  final RxBool isOccupationTypesLoading = false.obs;
  final Set<String> _allCategoriesCache = <String>{};
  final Map<String, int> _categoryToIdMap = <String, int>{};

  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isTalukasLoading = false.obs;
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;
  final Rxn<DropdownItem> selectedState = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedDistrict = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedTaluka = Rxn<DropdownItem>();

  final Rx<AppState> membersState = AppState.loading.obs;
  final RxList<Member> occupationMembers = <Member>[].obs;
  int _membersPage = 1;
  final int _membersPageSize = 20;
  final RxBool hasMoreMembers = true.obs;
  final RxBool isNextMembersPageLoading = false.obs;
  final RxnInt activeOccupationId = RxnInt();
  final RxString memberSearchQuery = ''.obs;
  String _lastMemberSearchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final allItem = DropdownItem(id: 0, text: 'All');
    occupationTypes.assignAll([allItem]);
    selectedOccupationType.value = allItem;
    _initData();
    debounce(
      searchQuery,
      (_) => loadOccupations(),
      time: const Duration(milliseconds: 300),
    );
    debounce(memberSearchQuery, (query) {
      final occId = activeOccupationId.value;
      if (occId != null && query != _lastMemberSearchQuery) {
        loadOccupationMembers(occId, refresh: true);
      }
    }, time: const Duration(milliseconds: 300));
  }

  Future<void> _initData() async {
    await loadOccupationTypes();
    await loadOccupations();
    await loadStates();
  }

  List<String> get availableCategories {
    final set = Set<String>.from(_allCategoriesCache);
    for (final item in occupationTypes) {
      final text = item.text.trim();
      if (text.isNotEmpty && text.toLowerCase() != 'all') {
        set.add(text);
      }
    }
    for (final occ in occupations) {
      final type = occ.occupationType?.trim();
      if (type != null && type.isNotEmpty) {
        set.add(type);
      }
    }
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<int> get selectedCategoryIds {
    final ids = <int>{};
    for (final cat in selectedCategories) {
      final catLower = cat.trim().toLowerCase();
      final id = _categoryToIdMap[catLower];
      if (id != null && id != 0) {
        ids.add(id);
      } else {
        for (final item in occupationTypes) {
          if (item.id != 0 && item.text.trim().toLowerCase() == catLower) {
            ids.add(item.id);
            _categoryToIdMap[catLower] = item.id;
            break;
          }
        }
      }
    }
    return ids.toList();
  }

  void applyCategoryFilters(List<String> categories) {
    selectedCategories.assignAll(categories);
    loadOccupations(refresh: true);
  }

  void resetCategoryFilters() {
    selectedCategories.clear();
    loadOccupations(refresh: true);
  }

  Future<void> loadStates() async {
    isStatesLoading.value = true;
    try {
      final results = await _familyRepository.getStates();
      states.assignAll(results);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'OccupationController.loadStates failed',
      );
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<List<DropdownItem>> fetchDistricts(int stateId) async {
    return _familyRepository.getDistricts(stateId);
  }

  Future<List<DropdownItem>> fetchTalukas(int districtId) async {
    return _familyRepository.getTalukas(districtId);
  }

  Future<void> applyFilters({
    required DropdownItem? state,
    required DropdownItem? district,
    required DropdownItem? taluka,
  }) async {
    selectedState.value = state;
    selectedDistrict.value = district;
    selectedTaluka.value = taluka;

    if (activeOccupationId.value != null) {
      loadOccupationMembers(activeOccupationId.value!, refresh: true);
    }
  }

  Future<void> resetFilters() async {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();

    if (activeOccupationId.value != null) {
      loadOccupationMembers(activeOccupationId.value!, refresh: true);
    }
  }

  int get activeLocationFilterCount {
    int count = 0;
    if (selectedState.value != null) count++;
    if (selectedDistrict.value != null) count++;
    if (selectedTaluka.value != null) count++;
    return count;
  }

  Future<void> loadOccupationTypes() async {
    isOccupationTypesLoading.value = true;
    try {
      final results = await _repository.getOccupationDropdown();
      occupationTypes.assignAll([DropdownItem(id: 0, text: 'All'), ...results]);
      for (final item in results) {
        if (item.id != 0 && item.text.trim().isNotEmpty) {
          _allCategoriesCache.add(item.text.trim());
          _categoryToIdMap[item.text.trim().toLowerCase()] = item.id;
        }
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'OccupationController.loadOccupationTypes failed',
      );
    } finally {
      isOccupationTypesLoading.value = false;
    }
  }

  void onOccupationTypeChanged(DropdownItem? type) {
    if (selectedOccupationType.value?.id == type?.id) return;
    selectedOccupationType.value = type;
    loadOccupations(occupationTypeId: type?.id, refresh: true);
  }

  Future<void> loadOccupationMembers(
    int occupationId, {
    bool refresh = true,
  }) async {
    if (refresh) {
      _membersPage = 1;
      hasMoreMembers.value = true;
      membersState.value = AppState.loading;
      occupationMembers.clear();
      _lastMemberSearchQuery = memberSearchQuery.value;
      activeOccupationId.value = occupationId;
    } else {
      if (!hasMoreMembers.value || isNextMembersPageLoading.value) return;
      isNextMembersPageLoading.value = true;
    }

    try {
      final results = await _repository.getOccupationMembers(
        occupationId: occupationId,
        search: memberSearchQuery.value.isNotEmpty
            ? memberSearchQuery.value
            : null,
        stateId: selectedState.value?.id,
        districtId: selectedDistrict.value?.id,
        talukaId: selectedTaluka.value?.id,
        pageNumber: _membersPage,
        pageSize: _membersPageSize,
      );

      if (results.isEmpty) {
        hasMoreMembers.value = false;
      } else {
        occupationMembers.addAll(results);
        _membersPage++;
        if (results.length < _membersPageSize) {
          hasMoreMembers.value = false;
        }
      }
      membersState.value = occupationMembers.isEmpty
          ? AppState.empty
          : AppState.data;
    } catch (e) {
      if (refresh) membersState.value = AppState.error;
    } finally {
      isNextMembersPageLoading.value = false;
    }
  }

  Future<void> loadOccupations({
    int? occupationTypeId,
    List<int>? occupationTypeIds,
    bool refresh = true,
  }) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      state.value = AppState.loading;
      occupations.clear();
      filteredOccupations.clear();
    } else {
      if (!hasMore.value || isNextPageLoading.value) return;
      isNextPageLoading.value = true;
    }

    try {
      final effectiveTypeIds = occupationTypeIds ??
          (selectedCategoryIds.isNotEmpty
              ? selectedCategoryIds
              : (occupationTypeId != null && occupationTypeId != 0
                  ? [occupationTypeId]
                  : (selectedOccupationType.value?.id != null &&
                          selectedOccupationType.value!.id != 0
                      ? [selectedOccupationType.value!.id]
                      : null)));

      final results = await _repository.getOccupations(
        occupationTypeIds: effectiveTypeIds,
        search: searchQuery.value,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      for (final occ in results) {
        final type = occ.occupationType?.trim();
        if (type != null && type.isNotEmpty) {
          _allCategoriesCache.add(type);
          if (occ.occupationTypeId != null && occ.occupationTypeId != 0) {
            _categoryToIdMap.putIfAbsent(
              type.toLowerCase(),
              () => occ.occupationTypeId!,
            );
          }
        }
      }

      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        final activeOccupations = results.where((occ) => occ.isActive).toList();
        occupations.addAll(activeOccupations);

        _currentPage++;
        if (results.length < _pageSize) {
          hasMore.value = false;
        }
      }
      filteredOccupations.assignAll(occupations);
      state.value = filteredOccupations.isEmpty
          ? AppState.empty
          : AppState.data;
    } catch (e) {
      if (refresh) state.value = AppState.error;
    } finally {
      isNextPageLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
  }

  void searchMembers(String query) {
    memberSearchQuery.value = query;
  }

  void clearMemberSearch() {
    if (memberSearchQuery.value.isEmpty) return;
    memberSearchQuery.value = '';
  }
}
