import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

class CommitteeController extends GetxController {
  final CommitteeRepository _repository;

  CommitteeController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final Rx<AppState> detailState = AppState.loading.obs;
  final RxList<CommitteeNode> committees = <CommitteeNode>[].obs;
  final Rx<CommitteeDetail?> committeeDetail = Rx<CommitteeDetail?>(null);
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadCommittees(), time: const Duration(milliseconds: 500));
  }

  Future<void> loadCommittees() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getCommittees(searchQuery: searchQuery.value);
      committees.assignAll(results);
      state.value = committees.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load committees', e, stack);
      state.value = AppState.error;
    }
  }

  Future<void> loadCommitteeDetail(int id) async {
    detailState.value = AppState.loading;
    try {
      final result = await _repository.getCommitteeDetail(id);
      committeeDetail.value = result;
      detailState.value = result == null ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load committee detail', e, stack);
      detailState.value = AppState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    loadCommittees();
  }

  void toggleNode(CommitteeNode node) {
    node.isExpanded = !node.isExpanded;
    committees.refresh();
  }
}
