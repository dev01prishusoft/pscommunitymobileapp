import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';

class CommitteeController extends GetxController {
  final CommitteeRepository _repository;

  CommitteeController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<CommitteeNode> committees = <CommitteeNode>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadCommittees(), time: const Duration(milliseconds: 500));
  }

  Future<void> loadCommittees() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getCommittees();
      
      if (searchQuery.value.isNotEmpty) {
        // Simple client side filter if API doesn't support deep search yet
        // but the repository is now calling the production endpoint
        committees.assignAll(results.where((c) => c.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList());
      } else {
        committees.assignAll(results);
      }
      
      state.value = committees.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load committees', e, stack);
      state.value = AppState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void toggleNode(CommitteeNode node) {
    node.isExpanded = !node.isExpanded;
    committees.refresh();
  }
}
