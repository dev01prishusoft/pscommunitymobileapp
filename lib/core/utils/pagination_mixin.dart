import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';

abstract class PaginationMixin<T> extends GetxController {
  final int pageSize = 20;
  
  final RxList<T> items = <T>[].obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final Rxn<Failure> paginationError = Rxn<Failure>();

  int page = 1;
  
  final ScrollController scrollController = ScrollController();
  final Debouncer searchDebouncer = Debouncer(milliseconds: 500);
  CancelToken? refreshCancelToken;
  CancelToken? loadMoreCancelToken;
  Future<Result<List<T>>> fetchPage(int page, CancelToken? cancelToken);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    refreshCancelToken?.cancel();
    loadMoreCancelToken?.cancel();
    searchDebouncer.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      loadNextPage();
    }
  }

  Future<void> refreshData({bool showInitialLoading = false}) async {
    if (isInitialLoading.value || isRefreshing.value) return;
    
    if (showInitialLoading) {
      isInitialLoading.value = true;
    } else {
      isRefreshing.value = true;
    }
    
    _resetPaginationState();
    
    refreshCancelToken?.cancel();
    refreshCancelToken = CancelToken();

    try {
      final result = await fetchPage(page, refreshCancelToken);
      _handlePageResult(result, isRefresh: true);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      paginationError.value = ServerFailure('An unexpected error occurred.');
    } finally {
      isInitialLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || isInitialLoading.value || isRefreshing.value || !hasMore.value) return;

    isLoadingMore.value = true;
    page++;
    
    loadMoreCancelToken?.cancel();
    loadMoreCancelToken = CancelToken();

    try {
      final result = await fetchPage(page, loadMoreCancelToken);
      _handlePageResult(result, isRefresh: false);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      paginationError.value = ServerFailure('An unexpected error occurred while loading more items.');
      page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _resetPaginationState() {
    page = 1;
    hasMore.value = true;
    paginationError.value = null;
  }

  void _handlePageResult(Result<List<T>> result, {required bool isRefresh}) {
    if (result is Success<List<T>>) {
      final data = result.data;
      if (isRefresh) {
        items.assignAll(data);
      } else {
        items.addAll(data);
      }
      
      hasMore.value = data.length >= pageSize;
      paginationError.value = null;
    } else if (result is Error<List<T>>) {
      paginationError.value = result.failure;
      if (!isRefresh) {
        page--;
      }
    }
  }

  void onSearchChanged(String query, void Function(String) onUpdateQuery) {
    onUpdateQuery(query);
    searchDebouncer.run(() => refreshData(showInitialLoading: false));
  }
}
