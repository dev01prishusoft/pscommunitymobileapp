import 'dart:async';

import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class AddedMembersController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final members = <Member>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final totalCount = 0.obs;
  final approvedCount = 0.obs;
  final rejectedCount = 0.obs;
  final requestedCount = 0.obs;

  final selectedTab = 'all'.obs;

  List<Member> get filteredMembers {
    if (selectedTab.value == 'all') {
      return members;
    }
    return members.where((m) {
      final s = m.approveStatus?.toLowerCase();
      if (selectedTab.value == 'requested') {
        return s != 'approved' && s != 'rejected';
      }
      return s == selectedTab.value;
    }).toList();
  }

  void setSelectedTab(String tab) {
    selectedTab.value = tab;
    _checkAndFetchMoreIfNeeded();
  }

  Future<void> _checkAndFetchMoreIfNeeded() async {
    if (filteredMembers.isEmpty && hasMore.value && !isLoading.value) {
      await fetchMembers();
    }
  }

  int _currentPage = 1;
  static const int _pageSize = 20;

  final searchQuery = ''.obs;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      refreshMembers();
    });
  }

  void refreshMembers() {
    _currentPage = 1;
    hasMore.value = true;
    members.clear();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        '/api/v1/member/mobile/list',
        queryParameters: {
          'Page': _currentPage,
          'PageSize': _pageSize,
          if (searchQuery.value.isNotEmpty) 'Search': searchQuery.value,
        },
      );

      if (response.data['succeeded'] == true) {
        final dataObj = response.data['data'];
        if (dataObj is Map<String, dynamic>) {
          final total = dataObj['totalCount'] as int? ?? 0;
          totalCount.value = dataObj['totalCount'] as int? ?? 0;
          approvedCount.value = dataObj['totalApproved'] as int? ?? 0;
          rejectedCount.value = dataObj['totalRejected'] as int? ?? 0;
          requestedCount.value = dataObj['totalRequested'] as int? ?? 0;
          final listData = dataObj['data'] as List<dynamic>? ?? [];
          final newMembers = listData
              .map((e) => Member.fromJson(e as Map<String, dynamic>))
              .toList();

          if (newMembers.isEmpty) {
            hasMore.value = false;
          } else {
            members.addAll(newMembers);
            _currentPage++;
            if (members.length >= total) {
              hasMore.value = false;
            }
          }
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
      if (filteredMembers.isEmpty && hasMore.value) {
        Future.microtask(() => _checkAndFetchMoreIfNeeded());
      }
    }
  }
}
