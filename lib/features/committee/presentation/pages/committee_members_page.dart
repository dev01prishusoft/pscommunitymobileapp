import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
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
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/responsive_containers.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';

class CommitteeMembersPage extends StatefulWidget {
  const CommitteeMembersPage({super.key});

  @override
  State<CommitteeMembersPage> createState() => _CommitteeMembersPageState();
}

class _CommitteeMembersPageState extends State<CommitteeMembersPage> {
  final CommitteeMembersController controller = Get.put(
    CommitteeMembersController(),
  );
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
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(LK.committeeMembers.tr, style: AppTextStyles.labelLarge),
      ),
      body: Obx(() {
        return AppStateView(
          state: controller.membersState.value,
          onRetry: () => controller.init(controller.node),
          child: _buildContent(
            controller.getGroupedMembers(controller.membersList),
          ),
        );
      }),
    );
  }

  Widget _buildContent(Map<String, List<CommitteeMember>> groups) {
    final roles = controller.getRoles(controller.membersList);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(
                  text: controller.searchQuery.value,
                ),
                focusNode: FocusNode(),
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: LK.searchCommittees.tr,
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              AppSpacing.vM,
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
        Expanded(
          child: groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: AppColors.grey.shade300,
                      ),
                      AppSpacing.vL,
                      Text(
                        LK.noMembersFound.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: groups.length,
                  padding: AppSpacing.pHXl,
                  separatorBuilder: (context, index) => AppSpacing.vL,
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

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          itemHeight: 56,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary,
            size: 20,
          ),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.replaceAll(':', ''),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final valKey = RoleMapper.getLabelKey(val);
                      return Text(
                        valKey != null ? valKey.tr : (val == 'All' ? LK.all.tr : val),
                        style: AppTextStyles.labelMedium,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.2),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleGroup(role),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate.withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group, color: AppColors.primary, size: 20),
                    AppSpacing.hM,
                    Expanded(
                      child: Text(
                        '${role.toUpperCase()} (${members.length})',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1),
            if (isExpanded)
              Column(
                children: members.map((member) {
                  return Column(
                    children: [
                      _buildMemberTile(member),
                      if (member != members.last) Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  void _showMemberDetails(CommitteeMember member) {
    AdaptiveBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      safeKeyboardInset: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: AppSpacing.pXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                      child: Text(
                        LK.memberDetails.tr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.mutedForeground),
                      onPressed: () => Get.back<void>(),
                    ),
                  ],
                ),
                Divider(height: 1),
                AppSpacing.vXxl,
                MemberAvatar(
                  imageUrl: null,
                  fallbackName: member.name,
                  radius: 40,
                ),
                AppSpacing.vL,
                Text(
                  member.name,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  '${member.roleName} (${member.roleTypeName})',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.vXxxl,
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment_ind,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            AppSpacing.hM,
                            Text(
                              LK.committeeInfo.tr.toUpperCase(),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      Padding(
                        padding: AppSpacing.pXl,
                        child: Column(
                          children: [
                            _buildDetailRow(LK.nameLabel.tr, node.name),
                            AppSpacing.vL,
                            _buildDetailRow(LK.role.tr, member.roleName),
                            AppSpacing.vL,
                            _buildDetailRow(
                              LK.startDateLabel.tr,
                              member.startDate?.split('T').first ?? '-',
                            ),
                            AppSpacing.vL,
                            _buildDetailRow(
                              LK.endDateLabel.tr,
                              member.endDate?.split('T').first ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vXxxl,
                ElevatedButton(
                  onPressed: () {
                    Get.back<void>();
                    Get.toNamed<void>(
                      AppRouter.memberProfile,
                      arguments: {'memberId': member.memberId},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 54),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: AppColors.white,
                      ),
                      AppSpacing.hM,
                      Text(
                        LK.viewProfile.tr,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
        Text(
          ':   ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(CommitteeMember member) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
      leading: MemberAvatar(
        imageUrl: null,
        fallbackName: member.name,
        radius: 24,
      ),
      title: Text(
        member.name,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Builder(
        builder: (context) {
          final nameKey = RoleMapper.getLabelKey(member.roleName);
          final typeKey = RoleMapper.getLabelKey(member.roleTypeName);
          return Text(
            '${LK.role.tr}: ${nameKey != null ? nameKey.tr : member.roleName} (${typeKey != null ? typeKey.tr : member.roleTypeName})',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: AppColors.mutedForeground,
      ),
      onTap: () => _showMemberDetails(member),
    );
  }
}
