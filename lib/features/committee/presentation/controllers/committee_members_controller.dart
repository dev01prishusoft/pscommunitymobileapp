import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';

class CommitteeMembersController extends GetxController {
  final CommitteeController _parentController = Get.find<CommitteeController>();

  // Expose parent controller's detail state for UI
  Rx<AppState> get detailState => _parentController.detailState;

  // Forward loadCommitteeDetail to parent controller
  Future<void> loadCommitteeDetail(int id) => _parentController.loadCommitteeDetail(id);

  // duplicate declaration removed

  // UI state
  final RxString selectedRole = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> expandedGroups = <String, bool>{}.obs;

  // Internal
  late CommitteeNode node;
  CommitteeDetail? get committeeDetail => _parentController.committeeDetail.value;

  @override
  void onInit() {
    // debounce search query similar to CommitteeController
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
    super.onInit();
  }

  void init(CommitteeNode committeeNode) {
    node = committeeNode;
    // load detail if needed
    if (_parentController.committeeDetail.value == null ||
        _parentController.committeeDetail.value?.name != node.name) {
      _parentController.loadCommitteeDetail(node.id);
    }
    // initialize expanded groups as all expanded
    expandedGroups.clear();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
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

  Map<String, List<CommitteeMember>> getGroupedMembers(List<CommitteeMember> members) {
    final roles = getRoles(members);
    if (!roles.contains(selectedRole.value)) {
      selectedRole.value = 'All';
    }
    final filtered = members.where((m) {
      final matchesRole = selectedRole.value == 'All' || m.roleName == selectedRole.value;
      final matchesSearch = searchQuery.value.isEmpty ||
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

  // Helper for date formatting (could be moved to utils later)
  String formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      return isoDate.split('T').first;
    } catch (_) {
      return isoDate;
    }
  }

  // Placeholder for filter application if needed
  void _applyFilters() {
    // No-op: UI will react to Rx changes
  }
}
