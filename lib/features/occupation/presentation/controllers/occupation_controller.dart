import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

class OccupationController extends GetxController {
  final OccupationRepository _repository;

  OccupationController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final Rx<AppState> detailsState = AppState.loading.obs;
  final RxList<OccupationItem> occupations = <OccupationItem>[].obs;
  final RxList<OccupationItem> filteredOccupations = <OccupationItem>[].obs;
  final RxList<DropdownItem> occupationTypes = <DropdownItem>[].obs;
  final RxString searchQuery = ''.obs;
  final Rxn<OccupationItem> selectedOccupation = Rxn<OccupationItem>();
  final Rxn<DropdownItem> selectedOccupationType = Rxn<DropdownItem>();

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with 'All' to prevent DropdownButton crash before API loads
    occupationTypes.assignAll([DropdownItem(id: 0, text: 'All')]);
    loadOccupationTypes();
    loadOccupations();

    // Debounce search
    debounce(searchQuery, (_) => loadOccupations(), time: const Duration(milliseconds: 300));
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

  Future<void> loadOccupationDetails(int id) async {
    detailsState.value = AppState.loading;
    try {
      final details = await _repository.getOccupationDetails(id);
      selectedOccupation.value = details;
      detailsState.value = AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load occupation details for id: $id', e, stack);
      detailsState.value = AppState.error;
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
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        occupations.addAll(results);
        
        // Apply search filter locally if any
        if (searchQuery.value.isNotEmpty) {
           final query = searchQuery.value.toLowerCase();
           final filtered = results.where((o) => o.name.toLowerCase().contains(query)).toList();
           filteredOccupations.addAll(filtered);
        } else {
           filteredOccupations.addAll(results);
        }

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
    // loadOccupations is called via debounce
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredOccupations.assignAll(occupations);
    state.value = occupations.isEmpty ? AppState.empty : AppState.data;
  }
}
