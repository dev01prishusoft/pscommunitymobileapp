import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_members_controller.dart';
import 'package:pscommunitymobileapp/core/mappers/role_mapper.dart';

class CommitteeMembersPage extends StatefulWidget {
  const CommitteeMembersPage({super.key});

  @override
  State<CommitteeMembersPage> createState() => _CommitteeMembersPageState();
}

class _CommitteeMembersPageState extends State<CommitteeMembersPage> {
  final CommitteeMembersController controller = Get.put(CommitteeMembersController());
  late CommitteeNode node;

  @override
  void initState() {
    super.initState();
    node = Get.arguments as CommitteeNode;
    controller.init(node);
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
        final detail = controller.committeeDetail;
        final groups = controller.getGroupedMembers(detail?.members ?? []);
        return AppStateView(
          state: controller.detailState.value,
          onRetry: () => controller.loadCommitteeDetail(node.id),
          child: detail == null ? const SizedBox.shrink() : _buildContent(groups),
        );
      }),
    );
  }

  Widget _buildContent(Map<String, List<CommitteeMember>> groups) {
    final roles = controller.getRoles(controller.committeeDetail?.members ?? []);
    return Column(
      children: [
        // Filters & Search
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: controller.searchQuery.value),
                focusNode: FocusNode(),
                onChanged: controller.onSearchChanged,
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
                      controller.selectedRole.value,
                      roles,
                      (val) => controller.selectRole(val),
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
                      Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        LK.noMembersFound.tr,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: groups.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                    },
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
    return Obx(() {
      final isExpanded = controller.expandedGroups[role] ?? true;
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleGroup(role),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${role.toUpperCase()} (${members.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
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
                itemBuilder: (context, index) => _buildMemberTile(members[index]),
              ),
          ],
        ),
      );
    });
  }

  void _showMemberDetails(CommitteeMember member) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      LK.memberDetails.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedForeground),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 24),
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              // Name & Role
              Text(member.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const SizedBox(height: 4),
              Text(
                '${member.roleName} (${member.roleTypeName})',
                style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              
              // Committee Info Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment_ind, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            LK.committeeInfo.tr.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildDetailRow(LK.nameLabel.tr, node.name),
                          const SizedBox(height: 16),
                          _buildDetailRow(LK.role.tr, member.roleName),
                          const SizedBox(height: 16),
                          _buildDetailRow(LK.startDateLabel.tr, member.startDate?.split('T').first ?? '--'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Button
              ElevatedButton(
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
                    Text(LK.viewProfile.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
        ),
        const Text(
          ':   ',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(CommitteeMember member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFF1F5F9),
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Builder(
        builder: (context) {
          final nameKey = RoleMapper.getLabelKey(member.roleName);
          final typeKey = RoleMapper.getLabelKey(member.roleTypeName);
          return Text(
            '${LK.role.tr}: ${nameKey != null ? nameKey.tr : member.roleName} (${typeKey != null ? typeKey.tr : member.roleTypeName})',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      trailing: const Icon(Icons.keyboard_arrow_right, color: AppColors.mutedForeground),
      onTap: () => _showMemberDetails(member),
    );
  }
}
