import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';

class TestPaginationController extends PaginationMixin<String> {
  // To mock API behavior
  Result<List<String>> Function(int page, CancelToken? cancelToken)? mockFetchPage;

  @override
  Future<Result<List<String>>> fetchPage(int page, CancelToken? cancelToken) async {
    if (mockFetchPage != null) {
      return mockFetchPage!(page, cancelToken);
    }
    return Success([]);
  }
}

void main() {
  late TestPaginationController controller;

  setUp(() {
    controller = TestPaginationController();
    controller.onInit(); // required to initialize scrollController listener
  });

  tearDown(() {
    controller.onClose();
  });

  test('refreshData fetches initial page and resets pagination', () async {
    controller.mockFetchPage = (page, token) => Success(List.generate(20, (i) => 'Item \$i'));
    
    await controller.refreshData(showInitialLoading: true);
    
    expect(controller.items.length, 20);
    expect(controller.page, 1);
    expect(controller.hasMore.value, true);
    expect(controller.isInitialLoading.value, false);
  });

  test('refreshData handles error gracefully', () async {
    controller.mockFetchPage = (page, token) => Error(ServerFailure('API Error'));
    
    await controller.refreshData();
    
    expect(controller.items.isEmpty, true);
    expect(controller.paginationError.value, isNotNull);
    expect(controller.paginationError.value!.message, 'API Error');
  });

  test('loadNextPage fetches page 2 and appends items', () async {
    // Initial fetch (page 1)
    controller.mockFetchPage = (page, token) => Success(List.generate(20, (i) => 'Page \$page Item \$i'));
    await controller.refreshData();
    
    // Fetch next page (page 2)
    controller.mockFetchPage = (page, token) => Success(List.generate(5, (i) => 'Page \$page Item \$i'));
    await controller.loadNextPage();
    
    expect(controller.items.length, 25);
    expect(controller.page, 2);
    // Since page 2 returned less than pageSize (20), hasMore should be false
    expect(controller.hasMore.value, false);
  });

  test('loadNextPage handles error by decrementing page counter', () async {
    // Initial fetch (page 1)
    controller.mockFetchPage = (page, token) => Success(List.generate(20, (i) => 'Item \$i'));
    await controller.refreshData();
    
    expect(controller.page, 1);

    // Fetch next page (page 2) fails
    controller.mockFetchPage = (page, token) => Error(ServerFailure('API Error on Page 2'));
    await controller.loadNextPage();
    
    expect(controller.items.length, 20); // Still only 20 items
    expect(controller.page, 1); // Page decremented back to 1
    expect(controller.paginationError.value, isNotNull);
  });

  test('loadNextPage does not execute if hasMore is false', () async {
    // Return fewer items than pageSize so hasMore becomes false
    controller.mockFetchPage = (page, token) => Success(['Item 1']);
    await controller.refreshData();
    
    expect(controller.hasMore.value, false);
    
    int callCount = 0;
    controller.mockFetchPage = (page, token) {
      callCount++;
      return Success(['Item 2']);
    };
    
    await controller.loadNextPage();
    
    expect(callCount, 0); // Should not have been called
    expect(controller.items.length, 1);
  });
}
