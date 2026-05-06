import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';

class FamilyController extends GetxController {
  final FamilyRepository _repository;

  FamilyController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<FamilyArea> areas = <FamilyArea>[].obs;
  final RxList<Family> families = <Family>[].obs;
  
  final Rx<AppState> familyListState = AppState.loading.obs;
  
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

  Future<void> loadFamilies(String areaName) async {
    familyListState.value = AppState.loading;
    try {
      final results = await _repository.getFamilies(areaName);
      families.assignAll(results);
      familyListState.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load families for area: $areaName', e, stack);
      familyListState.value = AppState.error;
    }
  }

  List<FamilyArea> get filteredAreas {
    if (selectedState.value != null || selectedDistrict.value != null || selectedTaluka.value != null) {
      return []; 
    }
    return areas;
  }

  void resetFilters() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
  }
}
