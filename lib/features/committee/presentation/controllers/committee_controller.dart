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

  int _currentPage = 1;
  final int _pageSize = 20;
  bool get hasMore => _hasMore;
  bool _hasMore = true;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadCommittees(isRefresh: false), time: const Duration(milliseconds: 500));
  }

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
        pageSize: _pageSize,
      );
      
      if (results.length < _pageSize) {
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
        _currentPage--; // Revert page count on failure
      }
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
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
    loadCommittees(isRefresh: true);
  }

  void toggleNode(CommitteeNode node) {
    node.isExpanded = !node.isExpanded;
    committees.refresh();
  }
}
