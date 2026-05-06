import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class FamilyController extends GetxController {
  final FamilyRepository _repository;

  FamilyController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<FamilyArea> areas = <FamilyArea>[].obs;
  
  final RxBool filtersExpanded = true.obs;
  final Rx<String?> selectedState = Rx<String?>(null);
  final Rx<String?> selectedDistrict = Rx<String?>(null);
  final Rx<String?> selectedTaluka = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadAreas();
  }

  Future<void> loadAreas() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getFamilyAreas();
      areas.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load family areas', e, stack);
      state.value = AppState.error;
    }
  }

  List<FamilyArea> get filteredAreas {
    if (selectedState.value != null || selectedDistrict.value != null || selectedTaluka.value != null) {
      return []; // Demonstrate empty state logic
    }
    return areas;
  }

  void resetFilters() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
  }
}
