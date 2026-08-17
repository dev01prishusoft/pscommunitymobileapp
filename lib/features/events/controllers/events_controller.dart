import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';

class EventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  EventsController(this._repository);
  final EventsRepositories _repository;

  late TabController tabController;
  final RxInt selectedTabIndex = 0.obs;

  final RxList<EventsData> upcomingEvents = <EventsData>[].obs;
  final RxList<EventsData> ongoingEvents = <EventsData>[].obs;
  final RxList<EventsData> pastEvents = <EventsData>[].obs;

  final RxInt upcomingCount = 0.obs;
  final RxInt ongoingCount = 0.obs;
  final RxInt pastCount = 0.obs;

  final RxBool isLoadingUpcoming = false.obs;
  final RxBool isLoadingOngoing = false.obs;
  final RxBool isLoadingPast = false.obs;

  int upcomingPage = 1, ongoingPage = 1, pastPage = 1;
  bool upcomingHasMore = true, ongoingHasMore = true, pastHasMore = true;

  final ScrollController upcomingScrollController = ScrollController();
  final ScrollController ongoingScrollController = ScrollController();
  final ScrollController pastScrollController = ScrollController();

  final RxBool isSearchVisible = false.obs;
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Debouncer searchDebouncer = Debouncer(milliseconds: 500);

  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (selectedTabIndex.value != tabController.index) {
        selectedTabIndex.value = tabController.index;
        _fetchEvents(selectedTabIndex.value + 1, isRefresh: true);
      }
    });

    upcomingScrollController.addListener(() {
      if (upcomingScrollController.position.pixels >=
          upcomingScrollController.position.maxScrollExtent - 200) {
        _loadMore(1);
      }
    });
    ongoingScrollController.addListener(() {
      if (ongoingScrollController.position.pixels >=
          ongoingScrollController.position.maxScrollExtent - 200) {
        _loadMore(2);
      }
    });
    pastScrollController.addListener(() {
      if (pastScrollController.position.pixels >=
          pastScrollController.position.maxScrollExtent - 200) {
        _loadMore(3);
      }
    });

    _initialLoadAll();
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    searchTextController.dispose();
    tabController.dispose();
    upcomingScrollController.dispose();
    ongoingScrollController.dispose();
    pastScrollController.dispose();
    searchDebouncer.dispose();
    super.onClose();
  }

  void onSearchQueryChanged(String val) {
    searchQuery.value = val;
    searchDebouncer.run(() {
      _initialLoadAll();
    });
  }

  Future<void> _initialLoadAll() async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    upcomingPage = 1;
    ongoingPage = 1;
    pastPage = 1;
    upcomingHasMore = true;
    ongoingHasMore = true;
    pastHasMore = true;
    upcomingEvents.clear();
    ongoingEvents.clear();
    pastEvents.clear();
    isLoadingUpcoming.value = true;
    isLoadingOngoing.value = true;
    isLoadingPast.value = true;

    await Future.wait([
      _fetchEvents(1, isRefresh: true),
      _fetchEvents(2, isRefresh: true),
      _fetchEvents(3, isRefresh: true),
    ]);
  }

  Future<void> refreshTab(int type) async {
    if (type == 1) {
      upcomingPage = 1;
      upcomingHasMore = true;
    } else if (type == 2) {
      ongoingPage = 1;
      ongoingHasMore = true;
    } else if (type == 3) {
      pastPage = 1;
      pastHasMore = true;
    }
    await _fetchEvents(type, isRefresh: true);
  }

  Future<void> _loadMore(int type) async {
    if (type == 1 && (isLoadingUpcoming.value || !upcomingHasMore)) return;
    if (type == 2 && (isLoadingOngoing.value || !ongoingHasMore)) return;
    if (type == 3 && (isLoadingPast.value || !pastHasMore)) return;

    if (type == 1) upcomingPage++;
    if (type == 2) ongoingPage++;
    if (type == 3) pastPage++;

    await _fetchEvents(type, isRefresh: false);
  }

  Future<void> _fetchEvents(int type, {required bool isRefresh}) async {
    if (!isRefresh) {
      if (type == 1) isLoadingUpcoming.value = true;
      if (type == 2) isLoadingOngoing.value = true;
      if (type == 3) isLoadingPast.value = true;
    }

    try {
      final pageNum = type == 1
          ? upcomingPage
          : (type == 2 ? ongoingPage : pastPage);
      final result = await _repository.getEvents(
        searchQuery: searchQuery.value,
        type: type == 1
            ? 'Upcoming'
            : type == 2
            ? 'Ongoing'
            : 'Past',
        pageNumber: pageNum,
        pageSize: 20,
        cancelToken: _cancelToken,
      );
      if (result is Success<PaginatedResponse<EventsData>>) {
        final data = result.data;
        final list = data.data.map((e) => _mapToEventModel(e, type)).toList();

        if (type == 1) {
          if (isRefresh)
            upcomingEvents.assignAll(list);
          else
            upcomingEvents.addAll(list);
          upcomingCount.value = data.totalRecords;
          upcomingHasMore = list.length >= 20;
        } else if (type == 2) {
          if (isRefresh)
            ongoingEvents.assignAll(list);
          else
            ongoingEvents.addAll(list);
          ongoingCount.value = data.totalRecords;
          ongoingHasMore = list.length >= 20;
        } else if (type == 3) {
          if (isRefresh)
            pastEvents.assignAll(list);
          else
            pastEvents.addAll(list);
          pastCount.value = data.totalRecords;
          pastHasMore = list.length >= 20;
        }
      } else if (result is Error) {
        if (!isRefresh) {
          if (type == 1) upcomingPage--;
          if (type == 2) ongoingPage--;
          if (type == 3) pastPage--;
        }
      }
    } catch (e) {
      if (!isRefresh) {
        if (type == 1) upcomingPage--;
        if (type == 2) ongoingPage--;
        if (type == 3) pastPage--;
      }
    } finally {
      if (type == 1) isLoadingUpcoming.value = false;
      if (type == 2) isLoadingOngoing.value = false;
      if (type == 3) isLoadingPast.value = false;
    }
  }

  EventsData _mapToEventModel(EventsData data, int type) {
    String? fullImageUrl = data.coverImage;
    if (fullImageUrl != null &&
        fullImageUrl.isNotEmpty &&
        !fullImageUrl.startsWith('http')) {
      final baseUrl = AppEnvironment.I.apiBaseUrl.endsWith('/')
          ? AppEnvironment.I.apiBaseUrl.substring(
              0,
              AppEnvironment.I.apiBaseUrl.length - 1,
            )
          : AppEnvironment.I.apiBaseUrl;
      final imagePath = fullImageUrl.startsWith('/')
          ? fullImageUrl
          : '/$fullImageUrl';
      fullImageUrl = '$baseUrl$imagePath';
      data.coverImage = fullImageUrl;
    }

    return data;
  }
}
