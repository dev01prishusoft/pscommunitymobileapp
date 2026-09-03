import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class MyEventsController extends GetxController {
  MyEventsController(this._repository);
  final EventsRepositories _repository;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<RegisteredEventItem> allItems = <RegisteredEventItem>[].obs;

  // Filter properties when redirected from a specific event
  final RxnInt targetEventId = RxnInt();
  final RxnString targetEventName = RxnString();
  final RxnString targetStatus = RxnString();

  int page = 1;
  final int pageSize = 20;
  bool hasMore = true;

  final ScrollController scrollController = ScrollController();
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });

    fetchRegisteredEvents();
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void setFilter({int? eventId, String? eventName, String? status}) {
    targetEventId.value = eventId;
    targetEventName.value = eventName;
    targetStatus.value = status;
  }

  void clearFilter() {
    targetEventId.value = null;
    targetEventName.value = null;
    targetStatus.value = null;
  }

  List<RegisteredEventItem> get displayedEvents {
    if (targetEventId.value != null) {
      final matches = allItems
          .where((e) => e.eventId == targetEventId.value)
          .toList();
      if (matches.isNotEmpty) {
        return matches;
      }
      if (targetEventName.value != null &&
          targetEventName.value!.isNotEmpty) {
        final nameMatches = allItems
            .where((e) =>
                (e.eventName ?? '').toLowerCase() ==
                targetEventName.value!.toLowerCase())
            .toList();
        if (nameMatches.isNotEmpty) return nameMatches;
      }
    }
    return allItems;
  }

  Future<void> fetchRegisteredEvents({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      hasMore = true;
    }

    if (page == 1) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final result = await _repository.getMyRegisteredEvents(
      page: page,
      pageSize: pageSize,
      cancelToken: _cancelToken,
    );
    printInfo(
      info: 'totalCount: ${result.dataOrNull?.data?.totalCount.toString()}',
    );
    printInfo(
      info:
          'items length: ${result.dataOrNull?.data?.items?.length.toString()}',
    );

    isLoading.value = false;
    isLoadingMore.value = false;

    if (result is Success<ApiResponse<RegisteredEventData>>) {
      final items = result.data.data?.items ?? [];
      final total = result.data.data?.totalCount ?? 0;

      if (page == 1) {
        allItems.assignAll(items);
      } else {
        allItems.addAll(items);
      }

      hasMore = allItems.length < total && items.isNotEmpty;
    } else if (result is Error<ApiResponse<RegisteredEventData>>) {
      if (page == 1) {
        hasError.value = true;
        errorMessage.value = result.failure.message;
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    page++;
    await fetchRegisteredEvents();
  }
}
