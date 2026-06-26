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

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
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
            Get.toNamed<void>(
              AppRouter.committeeDetails,
              arguments: currentNode,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (currentDepth > 0)
                  Container(
                    width: 2.w,
                    height: 40.h,
                    margin: EdgeInsets.only(
                      left: (currentDepth - 1) * 20.0,
                      right: 14,
                    ),
                    color: AppColors.border,
                  ),
                if (hasChildren)
                  InkWell(
                    onTap: () => controller.toggleNode(currentNode),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.chevron_right,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),

                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentNode.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentNode.memberCount > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${LK.membersCount.tr}: ${currentNode.memberCount}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
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
