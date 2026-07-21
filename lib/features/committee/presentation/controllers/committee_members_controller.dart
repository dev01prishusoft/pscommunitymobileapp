import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
class CommitteeMembersController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final Rx<AppState> membersState = AppState.empty.obs;
  final RxList<CommitteeMember> membersList = <CommitteeMember>[].obs;

  final Rx<DropdownItem?> selectedRole = Rx<DropdownItem?>(null);
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> expandedGroups = <String, bool>{}.obs;
  late CommitteeNode node;
  final _debouncer = Debouncer(milliseconds: 300);
  final RxList<DropdownItem> availableRoles = <DropdownItem>[].obs;

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  void init(CommitteeNode committeeNode) {
    node = committeeNode;
    _fetchMembers(node.id);
    _fetchRoles();
    expandedGroups.clear();

    // Re-fetch roles whenever the locale changes so the dropdown stays in the correct language
    if (Get.isRegistered<LocalizationService>()) {
      ever(Get.find<LocalizationService>().currentLocale, (_) {
        availableRoles.clear();
        _fetchRoles();
      });
    }
  }

  Future<void> _fetchRoles() async {
    try {
      final result = await _apiClient.getParsed<List<DropdownItem>>(
        ApiEndpoints.committeeRoleDropdown,
        fromJsonT: (json) => (json as List)
            .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (result is Success<ApiResponse<List<DropdownItem>>>) {
        availableRoles.value = result.data.data ?? [];
      }
    } catch (e) {
    }
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
        final allMembers = result.data.data ?? [];
        membersList.value = allMembers.where((m) => !isDateInPast(m.endDate)).toList();
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

  void selectRole(DropdownItem? role) {
    selectedRole.value = role;
  }

  void toggleGroup(String role) {
    final current = expandedGroups[role] ?? true;
    expandedGroups[role] = !current;
  }

  List<DropdownItem?> getRoles(List<CommitteeMember> members) {
    final roles = members.map((m) => m.roleName).where((r) => r.isNotEmpty).toSet();
    return [null, ...roles.map((r) => DropdownItem(id: 0, text: r))];
  }

  Map<String, List<CommitteeMember>> getGroupedMembers(
    List<CommitteeMember> members,
  ) {
    final roles = getRoles(members);
    if (selectedRole.value != null && !roles.any((r) => r?.id == selectedRole.value?.id && r?.text == selectedRole.value?.text)) {
      selectedRole.value = null;
    }
    final filtered = members.where((m) {
      final role = selectedRole.value;
      bool matchesRole = true;
      if (role != null) {
        if (role.id > 0 && m.committeeRoleId != null) {
          matchesRole = m.committeeRoleId == role.id;
        } else {
          matchesRole = m.roleName == role.text;
        }
      }
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
    return formatDateString(isoDate, fallback: '--');
  }

  void _applyFilters() {}
}
