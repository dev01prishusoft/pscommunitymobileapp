import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/library_item_card.dart';
import 'package:pscommunitymobileapp/core/widgets/library_search_bar.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_scaffold.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_separator.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';

class LibraryItemsPage extends StatelessWidget {
  const LibraryItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();

    return Obx(() {
      final category = controller.selectedCategory.value;
      final categoryTitle = category?.name ?? LK.library_items_fallback_title.tr;

      return DynamicAdScaffold(
        route: AppRouter.libraryItems,
        backgroundColor: AppColors.sfBackground,
        appBar: AppBar(
          title: Text(categoryTitle),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.loadCategoryItems(isRefresh: true),
          child: Column(
            children: [
              // Search Bar Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: LibrarySearchBar(
                  controller: controller.itemSearchController,
                  hintText: LK.library_search_items_hint.tr,
                  onChanged: controller.onItemSearchChanged,
                  onClear: () {
                    controller.itemSearchController.clear();
                    controller.onItemSearchChanged('');
                  },
                ),
              ),

              // Items List with pagination
              Expanded(
                child: AppStateView(
                  state: controller.itemsState.value,
                  errorMessage: controller.itemErrorMessage.value,
                  onRetry: () => controller.loadCategoryItems(isRefresh: true),
                  emptyIcon: Icons.menu_book_rounded,
                  emptyMessage: LK.library_no_items_found.tr,
                  child: ListView.separated(
                    controller: controller.itemScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    itemCount: controller.items.length +
                        (controller.isNextPageLoading.value ? 1 : 0),
                    separatorBuilder: (context, index) {
                      return DynamicAdSeparator(
                        route: AppRouter.libraryItems,
                        index: index,
                        regularSeparator: SizedBox(height: 6.h),
                      );
                    },
                    itemBuilder: (context, index) {
                      if (index >= controller.items.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final item = controller.items[index];
                      return LibraryItemCard(
                        item: item,
                        onTap: () => controller.openItem(item),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
