import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/library_category_card.dart';
import 'package:pscommunitymobileapp/core/widgets/library_search_bar.dart';
import 'package:pscommunitymobileapp/features/advertisement/models/ad_placement.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/ad_placement_slot.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/advertisement_card.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';

class LibraryCategoriesPage extends StatelessWidget {
  const LibraryCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LibraryController>()
        ? Get.find<LibraryController>()
        : Get.put(LibraryController());

    return Scaffold(
      backgroundColor: AppColors.sfBackground,
      appBar: AppBar(title: Text(LK.library_categories_title.tr)),
      body: Obx(() {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.loadCategories(isRefresh: true),
          child: Column(
            children: [
              // Search Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: LibrarySearchBar(
                  controller: controller.categorySearchController,
                  hintText: LK.library_search_categories_hint.tr,
                  onChanged: controller.onCategorySearchChanged,
                  onClear: () {
                    controller.categorySearchController.clear();
                    controller.onCategorySearchChanged('');
                  },
                ),
              ),

              // Categories List wrapped in AppStateView
              Expanded(
                child: AppStateView(
                  state: controller.categoriesState.value,
                  errorMessage: controller.categoryErrorMessage.value,
                  onRetry: () => controller.loadCategories(isRefresh: true),
                  emptyIcon: Icons.folder_off_rounded,
                  emptyMessage: LK.library_no_categories_found.tr,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final categoryCard = LibraryCategoryCard(
                        category: category,
                        onTap: () => controller.selectCategory(category),
                      );

                      // In-feed advertisement placed inside the list (between items)
                      final adTargetIndex = controller.categories.length >= 3
                          ? 1
                          : (controller.categories.length >= 2 ? 0 : 0);
                      if (index == adTargetIndex) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            categoryCard,
                            AdPlacementSlot(
                              placement: AdPlacement.libraryList,
                              layout: AdLayout.card,
                              padding: EdgeInsets.only(bottom: 12.h),
                            ),
                          ],
                        );
                      }
                      return categoryCard;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
