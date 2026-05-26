import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

class MockCommitteeRepository implements CommitteeRepository {
  bool shouldThrow = false;

  @override
  Future<Result<List<CommitteeNode>>> getCommittees({
    CancelToken? cancelToken,
    int pageNumber = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    if (shouldThrow) return Error(ServerFailure('API Error'));
    return Success([CommitteeNode(id: 1, name: 'Root')]);
  }

  @override
  Future<Result<CommitteeDetail?>> getCommitteeDetail(int id, {CancelToken? cancelToken}) async {
    if (shouldThrow) return Error(ServerFailure('API Error'));
    return Success(null);
  }
}

void main() {
  late CommitteeController controller;
  late MockCommitteeRepository repository;

  setUp(() {
    repository = MockCommitteeRepository();
    controller = CommitteeController(repository);
  });

  test('loadCommittees fetches data successfully', () async {
    await controller.refreshData(showInitialLoading: true);

    expect(controller.paginationError.value, isNull);
    expect(controller.items.length, 1);
    expect(controller.items.first.name, 'Root');
  });

  test('error gracefully sets error state', () async {
    repository.shouldThrow = true;
    await controller.refreshData(showInitialLoading: true);

    expect(controller.paginationError.value, isNotNull);
    expect(controller.items.isEmpty, true);
  });

  test('toggleNode toggles isExpanded and refreshes', () async {
    final node = CommitteeNode(id: 1, name: 'Test');
    expect(controller.nodeExpansion[node.id] ?? true, true);

    controller.toggleNode(node);

    expect(controller.nodeExpansion[node.id], false);
  });

  test('onSearchChanged updates query string', () {
    controller.onSearchChanged('search', controller.updateSearch);
    expect(controller.searchQuery.value, 'search');
  });
}
