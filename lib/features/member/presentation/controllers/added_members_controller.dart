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
          totalCount.value = total;
          
          final listData = dataObj['data'] as List<dynamic>? ?? [];
          final newMembers = listData.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
          
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
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }
}
