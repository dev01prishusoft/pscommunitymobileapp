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
  final RxBool isSearching = false.obs;
  String _lastQuery = '';

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadCommittees(showLoading: false), time: const Duration(milliseconds: 500));
  }

  Future<void> loadCommittees({bool showLoading = true}) async {
    // If it's a debounced call and query has not changed, return early
    if (!showLoading && searchQuery.value == _lastQuery) {
      return;
    }
    _lastQuery = searchQuery.value;

    if (showLoading) {
      state.value = AppState.loading;
    } else {
      isSearching.value = true;
    }

    try {
      final results = await _repository.getCommittees(searchQuery: searchQuery.value);
      committees.assignAll(results);
      state.value = committees.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load committees', e, stack);
      if (showLoading) {
        state.value = AppState.error;
      }
    } finally {
      isSearching.value = false;
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
    loadCommittees(showLoading: true);
  }

  void toggleNode(CommitteeNode node) {
    node.isExpanded = !node.isExpanded;
    committees.refresh();
  }
}
