import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';

import 'package:pscommunitymobileapp/core/utils/debouncer.dart';

class CommitteeMembersController extends GetxController {
  final CommitteeController _parentController = Get.find<CommitteeController>();
  Rx<AppState> get detailState => _parentController.detailState;
  Future<void> loadCommitteeDetail(int id) =>
      _parentController.loadCommitteeDetail(id);
  final RxString selectedRole = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> expandedGroups = <String, bool>{}.obs;
  late CommitteeNode node;
  CommitteeDetail? get committeeDetail =>
      _parentController.committeeDetail.value;
      
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  void init(CommitteeNode committeeNode) {
    node = committeeNode;
    if (_parentController.committeeDetail.value == null ||
        _parentController.committeeDetail.value?.name != node.name) {
      _parentController.loadCommitteeDetail(node.id);
    }
    expandedGroups.clear();
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
