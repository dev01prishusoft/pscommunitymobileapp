import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class OccupationController extends GetxController {
  final OccupationRepository _repository;

  OccupationController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<OccupationItem> occupations = <OccupationItem>[].obs;
  final RxList<OccupationItem> filteredOccupations = <OccupationItem>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOccupations();
  }

  Future<void> loadOccupations() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getOccupations();
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
