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

  @override
  void onInit() {
    super.onInit();
    // Initialize with 'All' to prevent DropdownButton crash before API loads
    occupationTypes.assignAll([DropdownItem(id: 0, text: 'All')]);
    loadOccupationTypes();
    loadOccupations();
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

  Future<void> loadOccupations({int? occupationTypeId}) async {
    state.value = AppState.loading;
    try {
      // Force occupationTypeId to 6 as per user request
      final results = await _repository.getOccupations(occupationTypeId: 6);
      occupations.assignAll(results);
      filteredOccupations.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load occupations', e, stack);
      state.value = AppState.error;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredOccupations.assignAll(occupations);
      state.value = occupations.isEmpty ? AppState.empty : AppState.data;
    } else {
      final results = occupations.where((o) {
        return o.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      filteredOccupations.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredOccupations.assignAll(occupations);
    state.value = occupations.isEmpty ? AppState.empty : AppState.data;
  }
}
