import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class CommitteeController extends GetxController {
  final CommitteeRepository _repository;

  CommitteeController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<CommitteeNode> committees = <CommitteeNode>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCommittees();
  }

  Future<void> loadCommittees() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getCommittees();
      committees.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load committees', e, stack);
      state.value = AppState.error;
    }
  }

  void toggleNode(CommitteeNode node) {
    node.isExpanded = !node.isExpanded;
    committees.refresh();
  }
}
