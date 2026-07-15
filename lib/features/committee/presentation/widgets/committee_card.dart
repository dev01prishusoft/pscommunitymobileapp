import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';

class CommitteeCard extends StatelessWidget {
  const CommitteeCard({required this.node, this.depth = 0, super.key});
  final CommitteeNode node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommitteeController>();

    return Card(
      elevation: 0,
      color: AppColors.grey.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Obx(() => _buildNodeTree(node, controller, 0)),
    );
  }

  Widget _buildNodeTree(
    CommitteeNode currentNode,
    CommitteeController controller,
    int currentDepth,
  ) {
    final isExpanded = controller.nodeExpansion[currentNode.id] ?? true;
    final hasChildren = currentNode.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed<void>(
              AppRouter.committeeDetails,
              arguments: currentNode,
            );
          },
          child: Container(
            color: currentDepth > 0
                ? AppColors.grey.withValues(alpha: 0.02)
                : AppColors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                if (currentDepth > 0)
                  Container(
                    width: 1.5.w,
                    height: 38.h,
                    margin: EdgeInsets.only(
                      left: (currentDepth - 1) * 20.w,
                      right: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                if (hasChildren)
                  InkWell(
                    onTap: () => controller.toggleNode(currentNode),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 22.r,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      size: 22.r,
                    ),
                  ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color:
                        (currentDepth == 0
                                ? AppColors.primary
                                : AppColors.secondary)
                            .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentDepth == 0
                        ? Icons.account_balance_rounded
                        : Icons.corporate_fare_rounded,
                    color: currentDepth == 0
                        ? AppColors.primary
                        : AppColors.secondary,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    currentNode.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: currentDepth == 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: currentDepth == 0 ? 14.sp : 13.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (currentNode.memberCount > 0) ...[
                  10.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${currentNode.memberCount} ${LK.membersCount.tr.toLowerCase()}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: currentNode.children
                .map(
                  (child) =>
                      _buildNodeTree(child, controller, currentDepth + 1),
                )
                .toList(),
          ),
      ],
    );
  }
}
