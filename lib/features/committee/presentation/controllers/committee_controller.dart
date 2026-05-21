import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

class CommitteeController extends GetxController {
  // Configurable pagination
  final int pageSize;

  // Expansion state for nodes (to avoid mutating model directly)
  final RxMap<int, bool> nodeExpansion = <int, bool>{}.obs;

  final CommitteeRepository _repository;

  CommitteeController(this._repository, {this.pageSize = 20});

  final Rx<AppState> state = AppState.loading.obs;
  final Rx<AppState> detailState = AppState.loading.obs;
  final RxList<CommitteeNode> committees = <CommitteeNode>[].obs;
  final Rx<CommitteeDetail?> committeeDetail = Rx<CommitteeDetail?>(null);
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  String _lastQuery = '';

  int _currentPage = 1;
  bool _hasMore = true;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadCommittees(isRefresh: false), time: const Duration(milliseconds: 500));
    loadCommittees();
  }

  bool get hasMore => _hasMore;

  Future<void> loadCommittees({bool isRefresh = true, bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
      _currentPage++;
    } else {
      if (!isRefresh && searchQuery.value == _lastQuery) return;
      _lastQuery = searchQuery.value;
      _currentPage = 1;
      _hasMore = true;

      if (isRefresh) {
        state.value = AppState.loading;
      } else {
        isSearching.value = true;
      }
    }

    try {
      final results = await _repository.getCommittees(
        searchQuery: searchQuery.value,
        pageNumber: _currentPage,
        pageSize: pageSize,
      );

      if (results.length < pageSize) {
        _hasMore = false;
      }

      if (isLoadMore) {
        committees.addAll(results);
      } else {
        committees.assignAll(results);
      }

      if (!isLoadMore) {
        state.value = committees.isEmpty ? AppState.empty : AppState.data;
      }
    } catch (e, stack) {
      AppLogger.e('Failed to load committees', e, stack);
      if (!isLoadMore) {
        state.value = AppState.error;
      } else {
        _currentPage--;
      }
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  int? _currentDetailId;

  Future<void> loadCommitteeDetail(int id) async {
    if (detailState.value == AppState.loading && _currentDetailId == id) return;
    _currentDetailId = id;
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
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    loadCommittees(isRefresh: true);
  }

  void toggleNode(CommitteeNode node) {
    final current = nodeExpansion[node.id] ?? true;
    nodeExpansion[node.id] = !current;
    committees.refresh();
  }
}
