import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

class FindMemberController extends PaginationMixin<Member> {
  FindMemberController(this._repository);
  final MemberRepository _repository;

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData(showInitialLoading: true);
  }

  @override
  Future<Result<List<Member>>> fetchPage(int page, CancelToken? cancelToken) async {
    final result = await _repository.searchMembers(
      query: searchQuery.value,
      pageNumber: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
    
    if (result is Success<PaginatedResponse<Member>>) {
      return Success(result.data.data);
    } else {
      return Error((result as Error).failure);
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
}
