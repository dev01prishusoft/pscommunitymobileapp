import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/role_mapper.dart';

class CommitteeMembersPage extends StatefulWidget {
  const CommitteeMembersPage({super.key});

  @override
  State<CommitteeMembersPage> createState() => _CommitteeMembersPageState();
}

class _CommitteeMembersPageState extends State<CommitteeMembersPage> {
  final controller = Get.find<CommitteeController>();
  late CommitteeNode node;
  String _selectedRole = 'All';
  String _searchQuery = '';
  final Map<String, bool> _expandedGroups = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    node = Get.arguments as CommitteeNode;
    if (controller.committeeDetail.value == null || 
        controller.committeeDetail.value?.name != node.name) {
      controller.loadCommitteeDetail(node.id);
    }
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _getRoles(List<CommitteeMember> members) {
    final roles = members.map((m) => m.roleName).toSet();
    return ['All', ...roles.where((r) => r != 'All')];
  }

  Map<String, List<CommitteeMember>> _getGroupedMembers(List<CommitteeMember> members) {
    final roles = _getRoles(members);
    if (!roles.contains(_selectedRole)) {
      _selectedRole = 'All';
    }
    final filtered = members.where((m) {
      final matchesRole = _selectedRole == 'All' || m.roleName == _selectedRole;
      final matchesSearch = _searchQuery.isEmpty || 
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.roleName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();

    final Map<String, List<CommitteeMember>> groups = {};
    for (var member in filtered) {
      groups.putIfAbsent(member.roleName, () => []).add(member);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          LK.committeeMembers.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final detail = controller.committeeDetail.value;
        return AppStateView(
          state: controller.detailState.value,
          onRetry: () => controller.loadCommitteeDetail(node.id),
          child: detail == null ? const SizedBox.shrink() : _buildContent(detail),
        );
      }),
    );
  }

  Widget _buildContent(CommitteeDetail detail) {
    final roles = _getRoles(detail.members);
    final groups = _getGroupedMembers(detail.members);

    return Column(
      children: [
        // Filters & Search
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onTapOutside: (event) => _focusNode.unfocus(),
                decoration: InputDecoration(
                  hintText: LK.searchCommittees.tr,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(
                      '${LK.role.tr}:',
                      _selectedRole,
                      roles,
                      (val) => setState(() => _selectedRole = val!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Member List
        Expanded(
          child: groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        LK.noMembersFound.tr,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: groups.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final role = groups.keys.elementAt(index);
                    final members = groups[role]!;
                    return _buildRoleGroup(role, members);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          itemHeight: 56,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
          style: const TextStyle(color: AppColors.secondary, fontSize: 13),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.replaceAll(':', ''), style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  Builder(
                    builder: (context) {
                      final valKey = RoleMapper.getLabelKey(val);
                      return Text(
                        valKey != null ? valKey.tr : val,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleGroup(String role, List<CommitteeMember> members) {
    final isExpanded = _expandedGroups[role] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedGroups[role] = !isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${role.toUpperCase()} (${members.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          if (isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildMemberTile(members[index]);
              },
            ),
        ],
      ),
    );
  }

  void _showMemberDetails(CommitteeMember member) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Modal Header with Stack for better alignment
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      LK.memberDetails.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.mutedForeground,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.person,
                                  size: 50, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            member.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${member.roleName} (${member.roleTypeName})',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.assignment, size: 18, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                LK.committeeInfo.tr.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(),
                          ),
                          _buildDetailRow(LK.nameLabel.tr, controller.committeeDetail.value?.name ?? '--'),
                          _buildDetailRow(LK.role.tr, member.roleName),
                          _buildDetailRow(LK.startDateLabel.tr, member.startDate?.split('T').first ?? '--'),
                          if (member.endDate != null)
                            _buildDetailRow(LK.endDateLabel.tr, member.endDate!.split('T').first),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.back<void>();
                  Get.toNamed<void>(
                    AppRouter.memberProfile,
                    arguments: {'memberId': member.memberId},
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      LK.viewProfile.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary, fontSize: 13),
            ),
          ),
          const Text('  :   ', style: TextStyle(color: AppColors.mutedForeground)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.secondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(CommitteeMember member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFFF1F5F9),
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Builder(
          builder: (context) {
            final nameKey = RoleMapper.getLabelKey(member.roleName);
            final typeKey = RoleMapper.getLabelKey(member.roleTypeName);
            return Text(
              '${LK.role.tr}: ${nameKey != null ? nameKey.tr : member.roleName} (${typeKey != null ? typeKey.tr : member.roleTypeName})',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            );
          }
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right, color: AppColors.mutedForeground),
      onTap: () => _showMemberDetails(member),
    );
  }
}
