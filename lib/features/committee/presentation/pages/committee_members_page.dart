import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/role_mapper.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/widgets/responsive_containers.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_members_controller.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    node = Get.arguments as CommitteeNode;
    controller.init(node);
    _searchController.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.committeeMembers.tr)),
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildFilterDropdown(
                  '${LK.role.tr}:',
                  controller.selectedRole.value,
                  roles,
                  (DropdownItem? val) => controller.selectRole(val),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AppTextField(
                    hint: LK.searchMember.tr,
                    controller: _searchController,
                    icon: Iconsax.search_normal_copy,
                    onChanged: controller.onSearchChanged,
                    suffixIcon: Obx(() {
                      return controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                controller.onSearchChanged('');
                              },
                            )
                          : const SizedBox.shrink();
                    }),
                  ),
                ),
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
                        Icons.person_off_rounded,
                        size: 64.r,
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        LK.noMembersFound.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: groups.length,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
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
    DropdownItem? value,
    List<DropdownItem?> options,
    ValueChanged<DropdownItem?> onChanged,
  ) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DropdownItem?>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 20.r,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<DropdownItem?>>((
            DropdownItem? val,
          ) {
            final displayText = val?.text ?? 'All';
            return DropdownMenuItem<DropdownItem?>(
              value: val,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.replaceAll(':', '').trim(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                      fontSize: 9.sp,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final valKey = RoleMapper.getLabelKey(displayText);
                      final resolvedText = valKey != null
                          ? valKey.tr
                          : (displayText == 'All' ? LK.all.tr : displayText);
                      return Text(
                        resolvedText,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
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
      ).paddingSymmetric(horizontal: 10.w),
    );
  }

  Widget _buildRoleGroup(String role, List<CommitteeMember> members) {
    return Obx(() {
      final isExpanded = controller.expandedGroups[role] ?? true;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleGroup(role),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                color: AppColors.grey.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.badge_rounded,
                        color: AppColors.primary,
                        size: 16.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        '${role.toUpperCase()} (${members.length})',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, thickness: 0.5),
              Column(
                children: members.map((member) {
                  return Column(
                    children: [
                      _buildMemberTile(member),
                      if (member != members.last)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.grey.withValues(alpha: 0.1),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    LK.memberDetails.tr,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.secondary,
                        size: 18.r,
                      ),
                    ),
                    onPressed: () => Get.back<void>(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 2.5,
                  ),
                ),
                child: MemberAvatar(
                  imageUrl: member.imageUrl,
                  fallbackName: member.name,
                  radius: 44.r,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                member.name,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  member.roleTypeName.trim().isEmpty
                      ? member.roleName
                      : '${member.roleName} (${member.roleTypeName})',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.08),
                  ),
                ),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    _buildDetailsItem(
                      Icons.account_balance_rounded,
                      LK.committeeInfo.tr,
                      node.name,
                    ),
                    Divider(
                      height: 24.h,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.1),
                    ),
                    _buildDetailsItem(
                      Icons.assignment_ind_rounded,
                      LK.role.tr,
                      member.roleName,
                    ),
                    if (member.reportsToName != null && member.reportsToName!.isNotEmpty) ...[
                      Divider(
                        height: 24.h,
                        thickness: 0.5,
                        color: AppColors.grey.withValues(alpha: 0.1),
                      ),
                      _buildDetailsItem(
                        Icons.supervisor_account_rounded,
                        LK.reportsToColon.tr.replaceAll(':', '').trim(),
                        member.reportsToName!,
                      ),
                    ],
                    Divider(
                      height: 24.h,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailsItem(
                            Icons.calendar_today_rounded,
                            LK.startDateLabel.tr,
                            formatDateString(member.startDate, fallback: '-'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildDetailsItem(
                            Icons.event_busy_rounded,
                            LK.endDateLabel.tr,
                            formatDateString(member.endDate, fallback: '-'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  Get.back<void>();
                  Get.toNamed<void>(
                    AppRouter.memberProfile,
                    arguments: {'memberId': member.memberId},
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.white,
                      size: 22.r,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      LK.viewProfile.tr,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildDetailsItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(CommitteeMember member) {
    return InkWell(
      onTap: () => _showMemberDetails(member),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: MemberAvatar(
                imageUrl: member.imageUrl,
                fallbackName: member.name,
                radius: 20.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Builder(
                    builder: (context) {
                      final nameKey = RoleMapper.getLabelKey(member.roleName);
                      final typeKey = RoleMapper.getLabelKey(
                        member.roleTypeName,
                      );
                      final roleNameStr = nameKey != null
                          ? nameKey.tr
                          : member.roleName;
                      final roleTypeStr = typeKey != null
                          ? typeKey.tr
                          : member.roleTypeName;

                      final text = roleTypeStr.trim().isEmpty
                          ? '${LK.role.tr}: $roleNameStr'
                          : '${LK.role.tr}: $roleNameStr ($roleTypeStr)';

                      return Text(
                        text,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary.withValues(alpha: 0.4),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
