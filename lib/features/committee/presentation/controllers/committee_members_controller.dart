import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';

class CommitteeMembersController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final Rx<AppState> membersState = AppState.empty.obs;
  final RxList<CommitteeMember> membersList = <CommitteeMember>[].obs;

  final RxString selectedRole = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> expandedGroups = <String, bool>{}.obs;
  late CommitteeNode node;
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  void init(CommitteeNode committeeNode) {
    node = committeeNode;
    _fetchMembers(node.id);
    expandedGroups.clear();
  }

  Future<void> _fetchMembers(int id) async {
    membersState.value = AppState.loading;
    try {
      final result = await _apiClient.getParsed<List<CommitteeMember>>(
        '/api/v1/CommitteeMember/by-committee/$id',
        fromJsonT: (json) => (json as List)
            .map((e) => CommitteeMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      
      if (result is Success<ApiResponse<List<CommitteeMember>>>) {
        membersList.value = result.data.data ?? [];
        membersState.value = membersList.isEmpty ? AppState.empty : AppState.data;
      } else {
        membersState.value = AppState.error;
      }
    } catch (e) {
      membersState.value = AppState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debouncer.run(() => _applyFilters());
  }

  void selectRole(String? role) {
    if (role != null) selectedRole.value = role;
  }

  void toggleGroup(String role) {
    final current = expandedGroups[role] ?? true;
    expandedGroups[role] = !current;
  }

  List<String> getRoles(List<CommitteeMember> members) {
    final roles = members.map((m) => m.roleName).toSet();
    return ['All', ...roles.where((r) => r != 'All')];
  }

  Map<String, List<CommitteeMember>> getGroupedMembers(
    List<CommitteeMember> members,
  ) {
    final roles = getRoles(members);
    if (!roles.contains(selectedRole.value)) {
      selectedRole.value = 'All';
    }
    final filtered = members.where((m) {
      final matchesRole =
          selectedRole.value == 'All' || m.roleName == selectedRole.value;
      final matchesSearch =
          searchQuery.value.isEmpty ||
          m.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          m.roleName.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();
    final Map<String, List<CommitteeMember>> groups = {};
    for (var member in filtered) {
      groups.putIfAbsent(member.roleName, () => []).add(member);
    }
    return groups;
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      return isoDate.split('T').first;
    } catch (_) {
      return isoDate;
    }
  }

  void _applyFilters() {}
}
