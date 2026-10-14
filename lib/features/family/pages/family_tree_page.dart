import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';
import 'package:pscommunitymobileapp/features/family/controllers/family_tree_controller.dart';
import 'package:pscommunitymobileapp/features/family/widgets/family_tree_layout.dart';

class FamilyTreePage extends StatefulWidget {
  const FamilyTreePage({super.key});

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  late final FamilyTreeController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<FamilyTreeController>()) {
      Get.delete<FamilyTreeController>(force: true);
    }
    controller = Get.put(FamilyTreeController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<FamilyTreeController>()) {
      Get.delete<FamilyTreeController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.treeCanvasBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back<void>(),
        ),
        title: Obx(() {
          final treeData = controller.treeData.value;
          final int membersCount = treeData?.totalMembers ?? 0;
          final int generationsCount = treeData?.maxGenerations ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LK.familyTree.tr,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.treeSlateDark,
                ),
              ),
              if (treeData != null)
                Text(
                  '$membersCount ${LK.membersCount.tr} • $generationsCount ${LK.Generations.tr}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(Icons.unfold_more_rounded, size: 19),
            color: AppColors.treeSlateMuted,
            onPressed: () => controller.expandAll(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AppLoadingIndicator());
        }
      
        final treeData = controller.treeData.value;
        if (treeData == null || treeData.head == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_tree_rounded,
                    size: 56,
                    color: AppColors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : LK.noDataFound.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.treeSlateMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadFamilyTree(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      LK.retry.tr,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      
        final layout = controller.getComputedLayout();
        if (layout == null) {
          return Center(
            child: Text(
              LK.Unabletorenderfamilytreelayout.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.treeSlateMuted,
              ),
            ),
          );
        }
      
        return Stack(
          children: [
            // 1. Natural Zoomable / Pannable Tree Canvas
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: controller.transformationController,
                boundaryMargin: const EdgeInsets.all(400),
                minScale: 0.2,
                maxScale: 2.8,
                constrained: false,
                child: FamilyTreeCanvasWidget(
                  layout: layout,
                  selectedMemberId: controller.selectedMember.value?.memberId,
                  onToggleBranch: (memberId) {
                    controller.toggleBranchCollapse(memberId);
                  },
                  onCardTap: (member) {
                    controller.selectMember(member);
                  },
                ),
              ),
            ),
      
            // 2. Floating Zoom In / Zoom Out Controls
            Positioned(
              right: 16,
              bottom: 46,
              child: _FloatingZoomControls(
                onZoomIn: () => controller.zoomIn(),
                onZoomOut: () => controller.zoomOut(),
              ),
            ),
      
            // 3. Compact Legend Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _LegendBar(),
            ),
          ],
        );
      }),
    );
  }
}

class _FloatingZoomControls extends StatelessWidget {
  const _FloatingZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    const double btnSize = 38.0;
    const double iconSize = 22.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: btnSize,
            height: btnSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_rounded, size: iconSize),
              color: AppColors.treeSlateText,
              onPressed: onZoomIn,
            ),
          ),
          Container(width: 26.0, height: 1, color: AppColors.grey.shade200),
          SizedBox(
            width: btnSize,
            height: btnSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove_rounded, size: iconSize),
              color: AppColors.treeSlateText,
              onPressed: onZoomOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  const _LegendBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(
            color: AppColors.treeMale,
            label: LK.male.tr,
            icon: Icons.male_rounded,
          ),
          _LegendItem(
            color: AppColors.treeFemale,
            label: LK.female.tr,
            icon: Icons.female_rounded,
          ),
          _LegendItem(
            color: AppColors.treeOther,
            label: LK.other.tr,
            icon: Icons.person_rounded,
          ),
          _LegendItem(
            color: AppColors.treeHead,
            label: LK.familyHead.tr,
            icon: Icons.star_rounded,
          ),
          _LegendItem(
            color: AppColors.treeSpouse,
            label: LK.Spouse.tr,
            icon: Icons.favorite_rounded,
          ),
          _LegendItem(
            color: AppColors.treeBranchLine,
            label: LK.Demised.tr,
            icon: Icons.eco_rounded,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  final Color color;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.0, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9.5,
            color: AppColors.treeSlateMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
