import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';

class FamilyAreasPage extends StatefulWidget {
  const FamilyAreasPage({super.key});

  @override
  State<FamilyAreasPage> createState() => _FamilyAreasPageState();
}

class _FamilyAreasPageState extends State<FamilyAreasPage> {
  final controller = Get.find<FamilyController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.resetFilters();
    controller.loadStates();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.family.tr),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter_search_copy),
            tooltip: LK.locationFilters.tr,
            onPressed: () {
              Get.dialog<void>(const _FilterDialog());
            },
          ),
        ],
      ),
      body: Obx(() {
        final state = controller.state.value;
        if (state == AppState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state == AppState.empty && controller.areas.isEmpty) {
          return const Center(
            child: _EmptyState(),
          ).paddingSymmetric(horizontal: 16.w);
        }

        return SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultsHeader(),
                SizedBox(height: 5.h),
                Obx(
                  () => AppStateView(
                    state: controller.state.value,
                    onRetry: controller.loadAreas,
                    child: Column(
                      children: [
                        _AreasList(areas: controller.areas),
                        if (controller.isNextPageLoading.value)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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

  Future<void> _applyFilters() async {
    controller.districts.assignAll(_localDistricts);
    controller.talukas.assignAll(_localTalukas);

    await controller.applyFilters(
      state: _tempState,
      district: _tempDistrict,
      taluka: _tempTaluka,
    );
    Get.back<void>();
  }

  Future<void> _resetFilters() async {
    await controller.resetFilters();
    Get.back<void>();
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
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Obx(
                () => _CustomDropdown(
                  hint: LK.selectState.tr,
                  value: _tempState,
                  options: controller.states,
                  onChanged: _onStateChanged,
                  isLoading: controller.isStatesLoading.value,
                ),
              ),
              SizedBox(height: 16.h),
              _CustomDropdown(
                hint: LK.selectDistrict.tr,
                value: _tempDistrict,
                options: _localDistricts,
                onChanged: _onDistrictChanged,
                isEnabled: _tempState != null,
                isLoading: _isDistrictsLoading,
              ),
              SizedBox(height: 16.h),
              _CustomDropdown(
                hint: LK.selectTaluka.tr,
                value: _tempTaluka,
                options: _localTalukas,
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
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.grey.shade700,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      LK.reset.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
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

class _ResultsHeader extends GetView<FamilyController> {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.areas.isEmpty) return const SizedBox.shrink();
      final isAll = controller.selectedTaluka.value == null;
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            Icon(Icons.map_rounded, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                isAll
                    ? LK.totalAreasAllLabel.trParams({
                        'count': controller.areas.length.toString(),
                      })
                    : LK.totalAreasLabel.trParams({
                        'taluka': controller.selectedTaluka.value!.text,
                        'count': controller.areas.length.toString(),
                      }),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AreasList extends StatelessWidget {
  const _AreasList({required this.areas});
  final List<FamilyArea> areas;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: areas.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final area = areas[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                      color: AppColors.primary.withValues(alpha: 0.08),
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
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                                    '${area.families} ${LK.familiesCount.tr}',
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
                                    '${area.members} ${area.members == 1 ? LK.member.tr : LK.membersCount.tr}',
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
                      color: AppColors.secondary,
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        controller.selectedState.value != null ||
        controller.selectedDistrict.value != null ||
        controller.selectedTaluka.value != null;

    return AppEmptyState(
      icon: Icons.map_outlined,
      secondaryIcon: Icons.location_on,
      title: LK.noAreasFound.tr,
      subtitle: LK.trySelectingDifferentFilters.tr,
      actionButton: hasActiveFilters
          ? ElevatedButton.icon(
              onPressed: controller.resetFilters,
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

class _CustomDropdown extends StatelessWidget {
  const _CustomDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.isEnabled = true,
    this.isLoading = false,
  });
  final String hint;
  final DropdownItem? value;
  final List<DropdownItem> options;
  final void Function(DropdownItem?) onChanged;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.white
            : AppColors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isEnabled
              ? (value != null
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.25))
              : AppColors.grey.withValues(alpha: 0.15),
          width: 1.2.w,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DropdownItem>(
          value: (value != null && options.any((o) => o.id == value!.id))
              ? options.firstWhere((o) => o.id == value!.id)
              : null,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
          ),
          isExpanded: true,
          icon: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isEnabled ? AppColors.secondary : AppColors.grey,
                  size: 20.sp,
                ),
          items: options.isEmpty
              ? null
              : options.map((option) {
                  return DropdownMenuItem<DropdownItem>(
                    value: option,
                    child: Text(
                      option.text,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          onChanged: isEnabled ? onChanged : null,
          borderRadius: BorderRadius.circular(14.r),
          dropdownColor: AppColors.white,
          elevation: 8,
          menuMaxHeight: 350,
        ),
      ),
    );
  }
}
