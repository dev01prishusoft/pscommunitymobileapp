import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class FindMemberController extends GetxController {
  final MemberRepository _repository;

  FindMemberController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<Member> members = <Member>[].obs;
  final RxString searchQuery = ''.obs;
  
  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search to avoid too many API calls
    debounce(searchQuery, (_) => loadMembers(), time: const Duration(milliseconds: 500));
  }

  Future<void> loadMembers({bool showLoading = true}) async {
    if (showLoading) state.value = AppState.loading;
    _currentPage = 1;
    hasMore.value = true;
    
    try {
      final results = await _repository.searchMembers(
        query: searchQuery.value,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      
      members.assignAll(results);
      hasMore.value = results.length >= _pageSize;
      state.value = members.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load members', e, stack);
      state.value = AppState.error;
    }
  }

  Future<void> loadMoreMembers() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    _currentPage++;
    
    try {
      final results = await _repository.searchMembers(
        query: searchQuery.value,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      
      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        members.addAll(results);
        hasMore.value = results.length >= _pageSize;
      }
    } catch (e, stack) {
      AppLogger.e('Failed to load more members', e, stack);
      _currentPage--; // Revert page on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    loadMembers();
  }
}
