import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_card.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/core/models/occupation_item.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/advertisement_card.dart';
import 'package:pscommunitymobileapp/features/occupation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/advertisement/models/ad_placement.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/ad_placement_slot.dart';

class OccupationDirectoryPage extends StatefulWidget {
  const OccupationDirectoryPage({super.key});

  @override
  State<OccupationDirectoryPage> createState() =>
      _OccupationDirectoryPageState();
}

class _OccupationDirectoryPageState extends State<OccupationDirectoryPage> {
  final OccupationController _controller = Get.find<OccupationController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _controller.clearSearch();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadOccupations(refresh: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? CupertinoSearchbar(
                onTapSuffix: () {
                  _searchController.clear();
                  _controller.clearSearch();
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    _isSearchVisible = false;
                  });
                },
                hintText: LK.searchOccupation.tr,
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchController.clear();
                    _controller.search('');
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  } else {
                    _controller.search(value);
                  }
                },
              )
            : Text(LK.occupationDirectory.tr),
        actions: [
          if (!_isSearchVisible)
            IconButton(
              icon: const Icon(Iconsax.search_normal_copy),
              onPressed: () {
                setState(() {
                  _isSearchVisible = true;
                });
              },
            ),
          IconButton(
            icon: Obx(() {
              final count = _controller.selectedCategories.length;
              if (count > 0) {
                return Badge(
                  label: Text('$count'),
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  child: const Icon(Iconsax.filter_search_copy),
                );
              }
              return const Icon(Iconsax.filter_search_copy);
            }),
            tooltip: LK.selectCategory.tr,
            onPressed: () {
              Get.dialog<void>(const _OccupationCategoryFilterDialog());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdPlacementSlot(
            placement: AdPlacement.occupationDirectory,
            layout: AdLayout.card,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
          ),
          Obx(() {
            if (_controller.selectedCategories.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 38.h,
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _controller.selectedCategories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final cat = _controller.selectedCategories[index];
                        return Chip(
                          label: Text(
                            cat,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          onDeleted: () {
                            final updated = List<String>.from(
                              _controller.selectedCategories,
                            )..remove(cat);
                            _controller.applyCategoryFilters(updated);
                          },
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _controller.resetCategoryFilters,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        LK.clearAll.tr,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.grey.shade600,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 6.h),
          Expanded(
            child: Obx(
              () => AppStateView(
                state: _controller.state.value,
                onRetry: _controller.loadOccupations,
                child: Column(
                  children: [
                    Expanded(
                      child: _controller.filteredOccupations.isEmpty
                          ? Center(
                              child: AppEmptyState(
                                icon: Icons.work_off_outlined,
                                secondaryIcon: Iconsax.search_normal_copy,
                                title: LK.noResultsFound.tr,
                                subtitle: LK.trySelectingDifferentFilters.tr,
                              ),
                            )
                          : GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 6.w,
                                    mainAxisSpacing: 10.h,
                                    childAspectRatio: 1.4,
                                  ),
                              padding: EdgeInsets.fromLTRB(
                                14.w,
                                10.h,
                                14.w,
                                50.h,
                              ),
                              itemCount: _controller.filteredOccupations.length,
                              itemBuilder: (context, index) {
                                final occ =
                                    _controller.filteredOccupations[index];
                                return _buildOccupationCard(occ);
                              },
                            ),
                    ),
                    if (_controller.isNextPageLoading.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationCard(OccupationItem occ) {
    return AppCard(
      borderRadius: 20.r,
      padding: EdgeInsets.all(10.r),
      elevation: 0.04,
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.08),
        width: 1.w,
      ),
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        _searchController.clear();
        _controller.clearSearch();
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _isSearchVisible = false;
        });
        await Get.toNamed<void>(
          AppRouter.occupationProfile,
          arguments: {'occupationId': occ.id, 'occupationName': occ.name},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              spacing: 5.w,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.white,
                  child: occ.logoUrl != null && occ.logoUrl!.isNotEmpty
                      ? CachedImg(
                          url: occ.logoUrl!,
                          height: 25.h,
                          width: 25.w,
                          memCacheHeight: 120,
                          memCacheWidth: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            height: 25.h,
                            width: 25.w,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            _getIconData(occ.iconKey),
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          _getIconData(occ.iconKey),
                          size: 20.r,
                          color: AppColors.primary,
                        ),
                ),
                _buildActionBadge(occ.count),
              ],
            ),
          ),
          5.verticalSpace,
          Text(
            occ.name,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          5.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildActionBadge(int? count) {
    final text = count == null
        ? "0"
        : count >= 1000
        ? "${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K+"
        : count.toString();
    return Expanded(
      child: Column(
        children: [
          Text(
            '${text}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            (count == null || count <= 1) ? LK.member.tr : LK.membersCount.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? key) {
    if (key == null) return Icons.work_rounded;
    switch (key) {
      case 'computer':
        return Icons.computer_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      default:
        return Icons.work_rounded;
    }
  }
}

class _OccupationCategoryFilterDialog extends StatefulWidget {
  const _OccupationCategoryFilterDialog();

  @override
  State<_OccupationCategoryFilterDialog> createState() =>
      _OccupationCategoryFilterDialogState();
}

class _OccupationCategoryFilterDialogState
    extends State<_OccupationCategoryFilterDialog> {
  final OccupationController _controller = Get.find<OccupationController>();
  late List<String> _tempSelectedCategories;
  final TextEditingController _categorySearchController =
      TextEditingController();
  String _categorySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedCategories = List<String>.from(_controller.selectedCategories);
    if (_controller.occupationTypes.isEmpty) {
      _controller.loadOccupationTypes();
    }
  }

  @override
  void dispose() {
    _categorySearchController.dispose();
    super.dispose();
  }

  void _onCategoryToggled(String category) {
    setState(() {
      final isSelected = _tempSelectedCategories.any(
        (c) => c.toLowerCase() == category.toLowerCase(),
      );
      if (isSelected) {
        _tempSelectedCategories.removeWhere(
          (c) => c.toLowerCase() == category.toLowerCase(),
        );
      } else {
        _tempSelectedCategories.add(category);
      }
    });
  }

  void _applyFilters() {
    _controller.applyCategoryFilters(_tempSelectedCategories);
    Get.back<void>();
  }

  void _resetFilters() {
    setState(() {
      _tempSelectedCategories.clear();
    });
    _controller.resetCategoryFilters();
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.15),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.filter_search_copy,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        LK.selectCategory.tr,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back<void>(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: _categorySearchController,
                    onChanged: (val) {
                      setState(() {
                        _categorySearchQuery = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: LK.selectCategory.tr,
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                      prefixIcon: Icon(
                        Iconsax.search_normal_copy,
                        size: 16.sp,
                        color: AppColors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  final allAvail = _controller.availableCategories;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tempSelectedCategories.isEmpty
                            ? LK.allCategories.tr
                            : '${_tempSelectedCategories.length} selected',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (allAvail.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_tempSelectedCategories.length >=
                                  allAvail.length) {
                                _tempSelectedCategories.clear();
                              } else {
                                _tempSelectedCategories = List<String>.from(
                                  allAvail,
                                );
                              }
                            });
                          },
                          child: Text(
                            _tempSelectedCategories.length >= allAvail.length
                                ? LK.clearAll.tr
                                : LK.selectAll.tr,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 8.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250.h),
                  child: Obx(() {
                    if (_controller.isOccupationTypesLoading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final allAvail = _controller.availableCategories;
                    final displayList = _categorySearchQuery.isEmpty
                        ? allAvail
                        : allAvail
                              .where(
                                (c) => c.toLowerCase().contains(
                                  _categorySearchQuery,
                                ),
                              )
                              .toList();

                    if (displayList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            LK.noResultsFound.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1.h,
                        color: AppColors.grey.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (context, index) {
                        final category = displayList[index];
                        final isSelected = _tempSelectedCategories.any(
                          (c) => c.toLowerCase() == category.toLowerCase(),
                        );
                        return InkWell(
                          borderRadius: BorderRadius.circular(10.r),
                          onTap: () => _onCategoryToggled(category),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22.w,
                                  height: 22.h,
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.grey.shade400,
                                      width: 1.5,
                                    ),
                                    onChanged: (_) =>
                                        _onCategoryToggled(category),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(LK.applyFilters.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey.shade700,
                      side: BorderSide(
                        color: AppColors.grey.shade400,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      LK.reset.tr,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
