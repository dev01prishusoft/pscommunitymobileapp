import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class BusinessController extends GetxController {
  final BusinessRepository _repository;

  BusinessController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<BusinessCategory> categories = <BusinessCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getCategories();
      categories.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load business categories', e, stack);
      state.value = AppState.error;
    }
  }
}
