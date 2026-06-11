import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class OccupationController extends GetxController {
  OccupationController(this._repository);

  final OccupationRepository _repository;

  final Rx<AppState> state = AppState.loading.obs;
  final Rx<AppState> detailsState = AppState.loading.obs;
  final RxList<OccupationItem> occupations = <OccupationItem>[].obs;
  final RxList<OccupationItem> filteredOccupations = <OccupationItem>[].obs;
  final RxList<DropdownItem> occupationTypes = <DropdownItem>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<DropdownItem> selectedOccupationType = Rxn<DropdownItem>();

  final Rx<AppState> membersState = AppState.loading.obs;
  final RxList<Member> occupationMembers = <Member>[].obs;
  int _membersPage = 1;
  final int _membersPageSize = 20;
  final RxBool hasMoreMembers = true.obs;
  final RxBool isNextMembersPageLoading = false.obs;

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize with 'All' item and select it by default
    final allItem = DropdownItem(id: 0, text: 'All');
    occupationTypes.assignAll([allItem]);
    selectedOccupationType.value = allItem;

    // Load types then occupations sequentially to avoid race conditions
    _initData();

    // Debounce search
    debounce(searchQuery, (_) => loadOccupations(), time: const Duration(milliseconds: 300));
  }

  Future<void> _initData() async {
    await loadOccupationTypes();
    await loadOccupations();
  }

  Future<void> loadOccupationTypes() async {
    try {
      final results = await _repository.getOccupationDropdown();
      occupationTypes.assignAll([
        DropdownItem(id: 0, text: 'All'),
        ...results,
      ]);
    } catch (e) {
      AppLogger.e('Failed to load occupation types', e);
    }
  }

  void onOccupationTypeChanged(DropdownItem? type) {
    selectedOccupationType.value = type;
    loadOccupations(occupationTypeId: type?.id);
  }

  Future<void> loadOccupationMembers(int occupationId, {bool refresh = true}) async {
    if (refresh) {
      _membersPage = 1;
      hasMoreMembers.value = true;
      membersState.value = AppState.loading;
      occupationMembers.clear();
    } else {
      if (!hasMoreMembers.value || isNextMembersPageLoading.value) return;
      isNextMembersPageLoading.value = true;
    }

    try {
      final results = await _repository.getOccupationMembers(
        occupationId: occupationId,
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
      membersState.value = occupationMembers.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load occupation members', e, stack);
      if (refresh) membersState.value = AppState.error;
    } finally {
      isNextMembersPageLoading.value = false;
    }
  }

  Future<void> loadOccupations({int? occupationTypeId, bool refresh = true}) async {
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
      final results = await _repository.getOccupations(
        occupationTypeId: occupationTypeId ?? selectedOccupationType.value?.id,
        search: searchQuery.value,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        final activeOccupations = results.where((occ) => occ.isActive).toList();
        occupations.addAll(activeOccupations);
        filteredOccupations.addAll(activeOccupations);

        _currentPage++;
        if (results.length < _pageSize) {
          hasMore.value = false;
        }
      }
      state.value = filteredOccupations.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load occupations', e, stack);
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
}
