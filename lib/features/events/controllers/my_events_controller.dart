import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class MyEventsController extends GetxController {
  MyEventsController(this._repository);
  final EventsRepositories _repository;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<RegisteredEventItem> allItems = <RegisteredEventItem>[].obs;
  final RxInt selectedTabIndex = 0.obs; // 0: Upcoming, 1: Ongoing, 2: Past
  final RxInt totalCount = 0.obs;

  // Search properties
  final RxBool isSearchVisible = false.obs;
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Debouncer searchDebouncer = Debouncer(milliseconds: 500);

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
    scrollController.addListener(_onScroll);
    fetchRegisteredEvents();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchTextController.dispose();
    searchDebouncer.dispose();
    super.onClose();
  }

  void onSearchQueryChanged(String val) {
    searchQuery.value = val;
    searchDebouncer.run(() {
      fetchRegisteredEvents(isRefresh: true);
    });
  }

  String getEventStatus(RegisteredEventItem item) {
    if (item.timePeriod != null && item.timePeriod.toString().isNotEmpty) {
      final tp = item.timePeriod.toString().toLowerCase();
      if (tp.contains('upcom')) return 'Upcoming';
      if (tp.contains('ongo')) return 'Ongoing';
      if (tp.contains('past')) return 'Past';
    }

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (item.eventStartDateTime != null &&
        item.eventStartDateTime!.isNotEmpty) {
      start = DateTime.tryParse(item.eventStartDateTime!);
    }
    if (item.eventEndDateTime != null && item.eventEndDateTime!.isNotEmpty) {
      end = DateTime.tryParse(item.eventEndDateTime!);
    }

    if (start != null) {
      if (end != null) {
        if (now.isBefore(start)) return 'Upcoming';
        if (now.isAfter(end)) return 'Past';
        return 'Ongoing';
      } else {
        if (now.year == start.year &&
            now.month == start.month &&
            now.day == start.day) {
          return 'Ongoing';
        } else if (now.isAfter(start)) {
          return 'Past';
        } else {
          return 'Upcoming';
        }
      }
    }

    if ((item.notes ?? '').toLowerCase().contains('over') ||
        (item.registrationStatusName ?? '').toLowerCase().contains('cancel')) {
      return 'Past';
    }

    return 'Upcoming';
  }

  List<RegisteredEventItem> get upcomingEvents =>
      allItems.where((e) => getEventStatus(e) == 'Upcoming').toList();

  List<RegisteredEventItem> get ongoingEvents =>
      allItems.where((e) => getEventStatus(e) == 'Ongoing').toList();

  List<RegisteredEventItem> get pastEvents =>
      allItems.where((e) => getEventStatus(e) == 'Past').toList();

  int get upcomingCount => upcomingEvents.length;
  int get ongoingCount => ongoingEvents.length;
  int get pastCount => pastEvents.length;

  void setFilter({int? eventId, String? eventName, String? status}) {
    targetEventId.value = eventId;
    targetEventName.value = eventName;
    targetStatus.value = status;

    if (status != null) {
      final st = status.toLowerCase();
      if (st.contains('ongo')) {
        selectedTabIndex.value = 1;
      } else if (st.contains('past')) {
        selectedTabIndex.value = 2;
      } else {
        selectedTabIndex.value = 0;
      }
    }
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
      if (matches.isNotEmpty) return matches;
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

    List<RegisteredEventItem> list;
    if (selectedTabIndex.value == 0) {
      list = upcomingEvents;
    } else if (selectedTabIndex.value == 1) {
      list = ongoingEvents;
    } else {
      list = pastEvents;
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((e) {
        final name = (e.eventName ?? '').toLowerCase();
        final code = (e.eventCode ?? '').toLowerCase();
        final reg = (e.registrationNumber ?? '').toLowerCase();
        final venue = (e.venueName?.toString() ?? '').toLowerCase();
        final type = (e.eventTypeName?.toString() ?? '').toLowerCase();
        return name.contains(q) ||
            code.contains(q) ||
            reg.contains(q) ||
            venue.contains(q) ||
            type.contains(q);
      }).toList();
    }

    return list;
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
      searchQuery: searchQuery.value.trim().isNotEmpty
          ? searchQuery.value.trim()
          : null,
      pageNumber: page,
      pageSize: pageSize,
      cancelToken: _cancelToken,
    );

    isLoading.value = false;
    isLoadingMore.value = false;

    if (result is Success<PaginatedResponse<RegisteredEventItem>>) {
      final items = result.data.data;
      final total = result.data.totalRecords;
      totalCount.value = total;

      if (page == 1) {
        allItems.assignAll(items);
      } else {
        allItems.addAll(items);
      }

      hasMore = allItems.length < total && items.isNotEmpty;
    } else if (result is Error<PaginatedResponse<RegisteredEventItem>>) {
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
