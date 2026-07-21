import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class PaginatedListView<T, C extends PaginationMixin<T>> extends GetView<C> {
  const PaginatedListView({
    super.key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyMessage,
    this.emptyIcon,
    this.padding = const EdgeInsets.all(16.0),
    this.onRetry,
    this.headerWidget,
  });

  final Widget Function(BuildContext, int, T) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onRetry;
  final Widget? headerWidget;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }

      if (controller.paginationError.value != null &&
          controller.items.isEmpty) {
        return AppErrorState(
          errorMessage: controller.paginationError.value?.message,
          onRetry: () {
            if (onRetry != null) onRetry!();
            controller.refreshData(showInitialLoading: true);
          },
        );
      }

      if (controller.items.isEmpty) {
        final emptyState = Center(
          child: AppEmptyState(
            icon: emptyIcon ?? Icons.search_off_rounded,
            secondaryIcon: emptyIcon != null ? null : Icons.search,
            title: emptyMessage ?? LK.noResultsFound.tr,
            subtitle: LK.trySelectingDifferentFilters.tr,
          ),
        );

        if (headerWidget == null) return emptyState;

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(showInitialLoading: false),
          color: AppColors.primary,
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            children: [
              headerWidget!,
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: emptyState,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshData(showInitialLoading: false),
        color: AppColors.primary,
        child: ListView.separated(
          controller: controller.scrollController,
          padding: padding,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.items.length +
              (controller.hasMore.value ? 1 : 0) +
              (headerWidget != null ? 1 : 0),
          separatorBuilder: (context, index) {
            if (headerWidget != null && index == 0) {
              return const SizedBox.shrink();
            }
            if (separatorBuilder != null) {
              return separatorBuilder!(
                context,
                headerWidget != null ? index - 1 : index,
              );
            }
            return const SizedBox.shrink();
          },
          itemBuilder: (context, index) {
            if (headerWidget != null) {
              if (index == 0) return headerWidget!;
              index -= 1;
            }
            if (index == controller.items.length) {
              return _buildPaginationLoader();
            }
            return itemBuilder(context, index, controller.items[index]);
          },
        ),
      );
    });
  }

  Widget _buildPaginationLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: controller.paginationError.value != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.paginationError.value?.message ??
                        LK.somethingWrong.tr,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.loadNextPage,
                    child: Text(LK.retry.tr),
                  ),
                ],
              )
            : const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
      ),
    );
  }
}
