import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class MyEventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MyEventsController(this._repository);
  final EventsRepositories _repository;

  late TabController tabController;
  final RxInt selectedTabIndex = 0.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<RegisteredEventItem> allItems = <RegisteredEventItem>[].obs;
  final RxList<RegisteredEventItem> upcomingEvents =
      <RegisteredEventItem>[].obs;
  final RxList<RegisteredEventItem> ongoingEvents = <RegisteredEventItem>[].obs;
  final RxList<RegisteredEventItem> pastEvents = <RegisteredEventItem>[].obs;

  final RxInt upcomingCount = 0.obs;
  final RxInt ongoingCount = 0.obs;
  final RxInt pastCount = 0.obs;

  int page = 1;
  final int pageSize = 20;
  bool hasMore = true;

  final ScrollController scrollController = ScrollController();
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (selectedTabIndex.value != tabController.index) {
        selectedTabIndex.value = tabController.index;
      }
    });

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
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    tabController.animateTo(index);
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
    isLoading.value = false;
    isLoadingMore.value = false;

    if (result is Success<ApiResponse<RegisteredEventsData>>) {
      final items = result.data.data?.items ?? [];
      final total = result.data.data?.totalCount ?? 0;

      if (page == 1) {
        allItems.assignAll(items);
      } else {
        allItems.addAll(items);
      }

      hasMore = allItems.length < total && items.isNotEmpty;
      _categorizeEvents();
    } else if (result is Error<ApiResponse<RegisteredEventsData>>) {
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

  void _categorizeEvents() {
    final now = DateTime.now();
    final List<RegisteredEventItem> upcoming = [];
    final List<RegisteredEventItem> ongoing = [];
    final List<RegisteredEventItem> past = [];

    for (final item in allItems) {
      final statusName = (item.registrationStatusName ?? '').toLowerCase();
      final notes = (item.notes ?? '').toLowerCase();

      // Explicit cancellation or completed status
      if (item.cancelledAt != null ||
          statusName.contains('cancel') ||
          notes.contains('over') ||
          notes.contains('completed')) {
        past.add(item);
        continue;
      }

      DateTime? regDate = DateTime.tryParse(item.registeredAt ?? '');
      if (regDate != null) {
        if (now.year == regDate.year &&
            now.month == regDate.month &&
            now.day == regDate.day) {
          ongoing.add(item);
        } else if (now.isAfter(regDate)) {
          past.add(item);
        } else {
          upcoming.add(item);
        }
      } else {
        if (statusName.contains('past') || statusName.contains('complete')) {
          past.add(item);
        } else {
          upcoming.add(item);
        }
      }
    }

    upcomingEvents.assignAll(upcoming);
    ongoingEvents.assignAll(ongoing);
    pastEvents.assignAll(past);

    upcomingCount.value = upcoming.length;
    ongoingCount.value = ongoing.length;
    pastCount.value = past.length;
  }

  List<RegisteredEventItem> get currentTabEvents {
    switch (selectedTabIndex.value) {
      case 0:
        return upcomingEvents;
      case 1:
        return ongoingEvents;
      case 2:
        return pastEvents;
      default:
        return upcomingEvents;
    }
  }
}
