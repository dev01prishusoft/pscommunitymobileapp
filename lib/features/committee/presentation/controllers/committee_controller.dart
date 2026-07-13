import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';

class CommitteeController extends PaginationMixin<CommitteeNode> {
  CommitteeController(this._repository);
  
  final RxMap<int, bool> nodeExpansion = <int, bool>{}.obs;

  final CommitteeRepository _repository;

  final Rx<AppState> detailState = AppState.loading.obs;
  final Rx<CommitteeDetail?> committeeDetail = Rx<CommitteeDetail?>(null);
  final RxString searchQuery = ''.obs;

  CancelToken? _detailCancelToken;

  @override
  void onInit() {
    super.onInit();
    refreshData(showInitialLoading: true);
  }

  @override
  Future<Result<List<CommitteeNode>>> fetchPage(int page, CancelToken? cancelToken) {
    return _repository.getCommittees(
      searchQuery: searchQuery.value,
      pageNumber: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
  }

  int? _currentDetailId;

  Future<void> loadCommitteeDetail(int id) async {
    if (_currentDetailId == id && committeeDetail.value != null && detailState.value == AppState.data) return;
    if (detailState.value == AppState.loading && _currentDetailId == id) return;
    
    _currentDetailId = id;
    detailState.value = AppState.loading;
    
    _detailCancelToken?.cancel();
    _detailCancelToken = CancelToken();
    
    try {
      final result = await _repository.getCommitteeDetail(id, cancelToken: _detailCancelToken);
      if (result is Success<CommitteeDetail?>) {
        committeeDetail.value = result.data;
        detailState.value = result.data == null ? AppState.empty : AppState.data;
      } else {
        detailState.value = AppState.error;
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      detailState.value = AppState.error;
    }
  }

  void updateSearch(String query) {
    onSearchChanged(query, (q) => searchQuery.value = q);
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchDebouncer.cancel();
    searchQuery.value = '';
    refreshData(showInitialLoading: true);
  }

  void toggleNode(CommitteeNode node) {
    final current = nodeExpansion[node.id] ?? true;
    nodeExpansion[node.id] = !current;
    items.refresh();
  }
}
