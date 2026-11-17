import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_scaffold.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_separator.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/core/widgets/custom_dropdown.dart';
import 'package:pscommunitymobileapp/core/models/family_area.dart';
import 'package:pscommunitymobileapp/features/family/controllers/family_controller.dart';

class FamilyAreasPage extends StatefulWidget {
  const FamilyAreasPage({super.key});

  @override
  State<FamilyAreasPage> createState() => _FamilyAreasPageState();
}

class _FamilyAreasPageState extends State<FamilyAreasPage> {
  final controller = Get.find<FamilyController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    controller.filterBy.value = 1;
    controller.resetFilters();
    controller.loadStates();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (controller.isNextPageLoading.value ||
        !controller.hasMore.value ||
        controller.state.value == AppState.loading) {
      return;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll > 0 && currentScroll > 0 && maxScroll - currentScroll <= 200) {
      controller.loadNextPage();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _onResetAll() {
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSearchVisible = false;
    });
    _scrollToTop();
    controller.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicAdScaffold(
      route: AppRouter.familyAreas,
      appBar: AppBar(
        title: _isSearchVisible && controller.filterBy.value == 2
            ? CupertinoSearchbar(
                hintText: LK.searchHint.tr,
                controller: _searchController,
                onTapSuffix: () {
                  _searchController.clear();
                  controller.clearNativePlaceSearch();
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    _isSearchVisible = false;
                  });
                },
                onChanged: (value) {
                  controller.updateNativePlaceSearch(value.trim());
                  if (value.isEmpty) {
                    _searchController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  }
                },
              )
            : Text(LK.familyByArea.tr),
        actions: [
          if (!_isSearchVisible)
            Obx(() {
              final filterBy = controller.filterBy.value;
              if (filterBy == 2) {
                return IconButton(
                  icon: const Icon(Iconsax.search_normal_copy),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = true;
                    });
                  },
                );
              }
              final count = controller.activeFilterCount;
              if (count > 0) {
                return IconButton(
                  icon: Badge(
                    label: Text('$count'),
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.white,
                    child: const Icon(Iconsax.filter_search_copy),
                  ),
                  onPressed: () {
                    Get.dialog<void>(const _FilterDialog());
                  },
                );
              }
              return IconButton(
                icon: const Icon(Iconsax.filter_search_copy),
                onPressed: () {
                  Get.dialog<void>(const _FilterDialog());
                },
              );
            }),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRadioButtons(),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;
              if (state == AppState.empty && controller.areas.isEmpty) {
                return Center(
                  child: _EmptyState(onReset: _onResetAll),
                ).paddingSymmetric(horizontal: 16.w);
              }

              return AppStateView(
                state: state,
                onRetry: () {
                  _scrollToTop();
                  controller.loadAreas();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AreasList(areas: controller.areas.toList()),
                        if (controller.isNextPageLoading.value)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRadioButtons() {
    return Obx(() {
      final filterBy = controller.filterBy.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.15),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                title: LK.area.tr.replaceFirst(RegExp(r':$'), ''),
                value: 1,
                isSelected: filterBy == 1,
                icon: Icons.location_on_rounded,
                onTap: () {
                  setState(() {
                    if (_isSearchVisible) {
                      _isSearchVisible = false;
                      _searchController.clear();
                    }
                  });
                  _scrollToTop();
                  controller.setFilterBy(1);
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildRadioOption(
                title: LK.Native_Place.tr,
                value: 2,
                isSelected: filterBy == 2,
                icon: Icons.home_work_rounded,
                onTap: () {
                  setState(() {});
                  _scrollToTop();
                  controller.setFilterBy(2);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRadioOption({
    required String title,
    required int value,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.2.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? AppColors.primary : AppColors.grey.shade600,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.sp,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog();

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  final controller = Get.find<FamilyController>();

  DropdownItem? _tempState;
  DropdownItem? _tempDistrict;
  DropdownItem? _tempTaluka;

  List<DropdownItem> _localDistricts = [];
  List<DropdownItem> _localTalukas = [];

  bool _isDistrictsLoading = false;
  bool _isTalukasLoading = false;

  @override
  void initState() {
    super.initState();
    _tempState = controller.selectedState.value;
    _tempDistrict = controller.selectedDistrict.value;
    _tempTaluka = controller.selectedTaluka.value;

    _localDistricts = List<DropdownItem>.from(controller.districts);
    _localTalukas = List<DropdownItem>.from(controller.talukas);
  }

  Future<void> _onStateChanged(DropdownItem? value) async {
    setState(() {
      _tempState = value;
      _tempDistrict = null;
      _tempTaluka = null;
      _localDistricts = [];
      _localTalukas = [];
      _isDistrictsLoading = value != null;
    });

    if (value != null) {
      try {
        final results = await controller.fetchDistricts(value.id);
        if (mounted) {
          setState(() {
            _localDistricts = results;
            _isDistrictsLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isDistrictsLoading = false);
      }
    }
  }

  Future<void> _onDistrictChanged(DropdownItem? value) async {
    setState(() {
      _tempDistrict = value;
      _tempTaluka = null;
      _localTalukas = [];
      _isTalukasLoading = value != null;
    });

    if (value != null) {
      try {
        final results = await controller.fetchTalukas(value.id);
        if (mounted) {
          setState(() {
            _localTalukas = results;
            _isTalukasLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isTalukasLoading = false);
      }
    }
  }

  void _onTalukaChanged(DropdownItem? value) {
    setState(() => _tempTaluka = value);
  }

  void _applyFilters() {
    controller.districts.assignAll(_localDistricts);
    controller.talukas.assignAll(_localTalukas);
    Get.back<void>();
    controller.applyFilters(
      state: _tempState,
      district: _tempDistrict,
      taluka: _tempTaluka,
    );
  }

  void _resetFilters() {
    Get.back<void>();
    controller.resetFilters();
  }

  bool get _hasSelection =>
      _tempState != null || _tempDistrict != null || _tempTaluka != null;

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
                      LK.locationFilters.tr,
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
                      padding: EdgeInsets.all(4),
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
              SizedBox(height: 24.h),
              Obx(
                () => CustomDropdown<DropdownItem>(
                  hint: LK.selectState.tr,
                  value: _tempState,
                  items: controller.states
                      .map(
                        (o) => DropdownMenuItem(
                          value: o,
                          child: Text(
                            o.text,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _onStateChanged,
                  isLoading: controller.isStatesLoading.value,
                ),
              ),
              SizedBox(height: 16.h),
              CustomDropdown<DropdownItem>(
                hint: LK.selectDistrict.tr,
                value: _tempDistrict,
                items: _localDistricts
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(
                          o.text,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onDistrictChanged,
                isEnabled: _tempState != null,
                isLoading: _isDistrictsLoading,
              ),
              SizedBox(height: 16.h),
              CustomDropdown<DropdownItem>(
                hint: LK.selectTaluka.tr,
                value: _tempTaluka,
                items: _localTalukas
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(
                          o.text,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onTalukaChanged,
                isEnabled: _tempDistrict != null,
                isLoading: _isTalukasLoading,
              ),
              if (_hasSelection) ...[
                SizedBox(height: 24.h),
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
                SizedBox(height: 4.h),
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
            ],
          ).paddingAll(24.w),
        ),
      ),
    );
  }
}

class _AreasList extends StatelessWidget {
  const _AreasList({required this.areas});
  final List<FamilyArea> areas;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: areas.length,
      separatorBuilder: (context, index) => DynamicAdSeparator(
        route: AppRouter.familyAreas,
        index: index,
        regularSeparator: SizedBox(height: 10.h),
      ),
      itemBuilder: (context, index) {
        final area = areas[index];
        return Container(
          key: ValueKey('${area.id}_${area.title}'),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.15),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              Get.toNamed<void>(
                AppRouter.familyMembers,
                arguments: {
                  'areaId': area.id,
                  'areaName': '${area.location} (${area.title})',
                  'membersCount': area.members,
                  'familiesCount': area.families,
                  'byArea': controller.filterBy.value == 1,
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (controller.filterBy.value == 1) ...[
                          SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              size: 14.sp,
                              color: AppColors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                area.location,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        ],
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    size: 12.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${area.families} ${area.families <= 1 ? LK.family.tr : LK.familiesCount.tr}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 12.sp,
                                    color: AppColors.secondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${area.members} ${area.members <= 1 ? LK.member.tr : LK.membersCount.tr}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends GetView<FamilyController> {
  const _EmptyState({this.onReset});
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        controller.selectedState.value != null ||
        controller.selectedDistrict.value != null ||
        controller.selectedTaluka.value != null ||
        controller.nativePlaceSearchQuery.value.isNotEmpty;

    return AppEmptyState(
      icon: Icons.map_outlined,
      secondaryIcon: Icons.location_on,
      title: LK.noDataFound.tr,
      subtitle: LK.trySelectingDifferentFilters.tr,
      actionButton: hasActiveFilters
          ? ElevatedButton.icon(
              onPressed: onReset ?? controller.resetFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(LK.reset.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            )
          : null,
    );
  }
}
