import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class BusinessController extends GetxController {
  BusinessController(this._repository);
  final BusinessRepository _repository;

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<BusinessCategory> categories = <BusinessCategory>[].obs;

  Future<void> loadCategories() async {
    state.value = AppState.loading;
    try {
      final result = await _repository.getCategories();
      if (result is Success) {
        final results = result.dataOrNull!;
        categories.assignAll(results);
        state.value = results.isEmpty ? AppState.empty : AppState.data;
      } else {
        state.value = AppState.error;
      }
    } catch (e, stack) {
      AppLogger.e('Failed to load business categories', e, stack);
      state.value = AppState.error;
    }
  }
}
