import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MockMemberRepository implements MemberRepository {
  bool shouldThrow = false;
  int lastPageNumber = 1;
  String? lastQuery;

  @override
  Future<Result<PaginatedResponse<Member>>> getMembers() async => Error(ServerFailure('API Error'));

  @override
  Future<Result<PaginatedResponse<Member>>> searchMembers({
    CancelToken? cancelToken,
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    lastPageNumber = pageNumber;
    lastQuery = query;

    if (shouldThrow) return Error(ServerFailure('API Error'));

    List<Member> items = [];
    if (pageNumber == 1) {
      items = List.generate(20, (i) => Member(memberId: i, firstName: 'A', lastName: 'B'));
    } else if (pageNumber == 2) {
      items = List.generate(5, (i) => Member(memberId: 20 + i, firstName: 'C', lastName: 'D'));
    }
    
    return Success(PaginatedResponse(data: items, totalRecords: 25, pageSize: 20, pageNumber: pageNumber, totalPages: 2, succeeded: true));
  }

  @override
  Future<Result<bool>> updateProfile(Member member) async {
    if (shouldThrow) return Error(ServerFailure('API Error'));
    return const Success(true);
  }

  @override
  Future<Result<bool>> deleteAccount(int id) async {
    if (shouldThrow) return Error(ServerFailure('API Error'));
    return const Success(true);
  }
}

void main() {
  late FindMemberController controller;
  late MockMemberRepository repository;

  setUp(() {
    repository = MockMemberRepository();
    controller = FindMemberController(repository);
  });

  test('loadMembers resets pagination and loads page 1', () async {
    await controller.refreshData(showInitialLoading: true);

    expect(controller.paginationError.value, isNull);
    expect(controller.items.length, 20);
    expect(controller.hasMore.value, true);
    expect(repository.lastPageNumber, 1);
  });

  test('loadMoreMembers increments page and appends data', () async {
    await controller.refreshData(); // Page 1

    expect(controller.items.length, 20);
    expect(repository.lastPageNumber, 1);

    await controller.loadNextPage(); // Page 2

    expect(controller.items.length, 25);
    expect(repository.lastPageNumber, 2);
    expect(controller.hasMore.value, false);
  });

  test('onSearchChanged updates query', () {
    controller.onSearchChanged('test', controller.updateSearch);
    expect(controller.searchQuery.value, 'test');
  });

  test('error state triggers AppState.error', () async {
    repository.shouldThrow = true;
    await controller.refreshData(showInitialLoading: true);

    expect(controller.paginationError.value, isNotNull);
    expect(controller.items.isEmpty, true);
  });
}
