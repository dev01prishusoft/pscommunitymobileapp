import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/widgets/responsive_containers.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MarriagePage extends GetView<MarriageController> {
  const MarriagePage({super.key});

  void _showAdvancedFilters(BuildContext context) {
    controller.isAdvancedFiltersOpen.value = true;
    AdaptiveBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      child: _AdvancedFiltersBottomSheet(controller: controller),
    ).then((_) {
      controller.isAdvancedFiltersOpen.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.isSearchVisible.value) {
            return CupertinoTextField(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              prefix: Icon(
                Iconsax.search_normal_copy,
                size: 15,
              ).paddingOnly(left: 10),
              suffix: GestureDetector(
                onTap: () {
                  controller.searchTextController.clear();
                  controller.searchQuery.value = '';
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.isSearchVisible.value = false;
                },
                child: Icon(Iconsax.close_circle_copy).paddingOnly(right: 10),
              ),
              placeholder: LK.searchByFirstNameHint.tr,
              controller: controller.searchTextController,
              onChanged: (val) {
                controller.searchQuery.value = val;
              },
            );
          }
          return Text(LK.marriage.tr);
        }),
        actions: [
          Obx(() {
            if (controller.isSearchVisible.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Iconsax.search_normal_copy),
              onPressed: () {
                controller.isSearchVisible.value = true;
              },
            );
          }),

          IconButton(
            icon: Icon(Iconsax.filter_search_copy),
            tooltip: LK.advancedFilters.tr,
            onPressed: () => _showAdvancedFilters(context),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          Obx(() {
            if (controller.state.value == AppState.data) {
              return SliverToBoxAdapter(child: _buildFilterControlsCard());
            } else {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
          }),
          Obx(() {
            if (controller.state.value == AppState.data) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == controller.filteredMembers.length) {
                      return controller.isNextPageLoading.value
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    return _MarriageMemberCard(
                      member: controller.filteredMembers[index],
                    );
                  },
                  childCount:
                      controller.filteredMembers.length +
                      (controller.hasMore.value ? 1 : 0),
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: AppStateView(
                    state: controller.state.value,
                    emptyMessage: LK.noMatchesFound.tr,
                    child: const SizedBox.shrink(),
                  ),
                ),
              );
            }
          }),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color textColor,
    required bool isMale,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 2.h),
              Text(
                count,
                style: AppTextStyles.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  height: 1.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard2({
    IconData? icon,
    Color? iconColor,
    required String label,
    required Widget widget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconColor!.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14.sp),
          ),
          SizedBox(width: 10.w),
        ],
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.clip,
        ),
        Spacer(),
        widget,
      ],
    );
  }

  Widget _buildFilterControlsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 1.2.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: LK.unmarriedMale.tr,
                      count: controller.unmarriedMaleCount.toString(),
                      icon: Iconsax.man_copy,
                      iconColor: AppColors.blue,
                      textColor: AppColors.blue,
                      isMale: true,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      label: LK.unmarriedFemale.tr,
                      count: controller.unmarriedFemaleCount.toString(),
                      icon: Iconsax.woman_copy,
                      iconColor: Colors.pink,
                      textColor: Colors.pink,
                      isMale: false,
                    ),
                  ),
                ],
              );
            }),
            Divider(color: AppColors.grey.withValues(alpha: 0.1), height: 16.h),
            _buildSummaryCard2(
              icon: Iconsax.heart,
              iconColor: AppColors.red,
              label: LK.lookingForMarriage.tr,
              widget: Obx(
                () => SizedBox(
                  height: 25.h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch(
                      value: controller.lookingForMarriage.value,
                      onChanged: (val) {
                        controller.lookingForMarriage.value = val;
                      },
                      activeThumbColor: AppColors.red,
                    ),
                  ),
                ),
              ),
            ),
            Divider(color: AppColors.grey.withValues(alpha: 0.1), height: 16.h),
            _buildSummaryCard2(
              label: LK.gender.tr,
              icon: Iconsax.user_copy,
              iconColor: AppColors.primary,
              widget: Obx(
                () => Wrap(
                  runSpacing: 5.h,
                  children: ['All', 'Male', 'Female'].map((gender) {
                    final isSelected =
                        controller.selectedGender.value == gender;
                    final displayLabel = gender == 'All'
                        ? LK.all.tr
                        : (gender == 'Male' ? LK.male.tr : LK.female.tr);
                    return Container(
                      margin: EdgeInsets.only(right: 6.w),
                      child: ChoiceChip(
                        showCheckmark: false,
                        visualDensity: VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                        padding: EdgeInsets.zero,
                        label: Text(
                          displayLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.primary,
                            fontSize: 10.sp,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedGender.value = gender;
                          }
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.transparent,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarriageMemberCard extends StatelessWidget {
  const _MarriageMemberCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed<void>(
              AppRouter.memberProfile,
              arguments: {'memberId': member.memberId},
            );
          },
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemberAvatar(
                  imageUrl: member.profilePhotoFullUrl,
                  gender: member.gender,
                  fallbackName: member.name,
                  radius: 28.r,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.grey.shade400,
                            size: 20.sp,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          if (member.age > 0)
                            _buildBadge(
                              '${member.age} ${LK.ageYears.tr}',
                              Icons.cake_outlined,
                              AppColors.primary,
                            ),
                          if (member.gotra.isNotEmpty)
                            _buildBadge(
                              member.gotra,
                              Iconsax.hierarchy_copy,
                              AppColors.chart2,
                            ),
                          if (member.occupation.isNotEmpty)
                            _buildBadge(
                              member.occupation,
                              Iconsax.briefcase_copy,
                              AppColors.chart5,
                            ),
                        ],
                      ),
                      if (member.area.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                member.area,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            '${LK.lookingForMarriage.tr}: ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: (member.isLookingforMarriage == true)
                                  ? AppColors.green.withValues(alpha: 0.08)
                                  : AppColors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: (member.isLookingforMarriage == true)
                                    ? AppColors.green.withValues(alpha: 0.15)
                                    : AppColors.red.withValues(alpha: 0.15),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              (member.isLookingforMarriage == true)
                                  ? LK.yes.tr
                                  : LK.no.tr,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: (member.isLookingforMarriage == true)
                                    ? AppColors.green
                                    : AppColors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedFiltersBottomSheet extends StatelessWidget {
  const _AdvancedFiltersBottomSheet({required this.controller});

  final MarriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  width: 1.w,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.filter_search_copy, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  LK.advancedFilters.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.isAdvancedFiltersOpen.value = false;
                    Get.back<void>();
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldSection(
                    label: LK.ageRangeLabel.tr,
                    icon: Iconsax.calendar_copy,
                    child: _buildFilterRow(
                      fromRx: controller.selectedAgeFrom,
                      toRx: controller.selectedAgeTo,
                      errorRx: controller.ageError,
                      staticItems: controller.ages,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.heightRangeLabel.tr,
                    icon: Iconsax.weight_copy,
                    child: _buildFilterRow(
                      fromRx: controller.selectedHeightFrom,
                      toRx: controller.selectedHeightTo,
                      errorRx: controller.heightError,
                      staticItems: controller.heights,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.gotraLabel.tr,
                    icon: Iconsax.hierarchy_copy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _FilterDropdownField(
                                rxValue: controller.selectedGotra,
                                rxItems: controller.dynamicGotras,
                                mapper: _translateFallback,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Obx(
                              () => SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: Checkbox(
                                  value: controller.excludeSameGotra.value,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) =>
                                      controller.excludeSameGotra.value = val!,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              LK.excludeSameGotra.tr,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.maritalStatusLabel.tr,
                    icon: Iconsax.info_circle_copy,
                    child: _FilterDropdownField(
                      rxValue: controller.selectedMaritalStatus,
                      staticItems: controller.dynamicMaritalStatuses,
                      mapper: (val) {
                        if (val == 'All') return LK.all.tr;
                        final key = MaritalStatusMapper.getLabelKey(val);
                        return key != null ? key.tr : val;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.residenceLabel.tr,
                    icon: Iconsax.location_copy,
                    child: Column(
                      children: [
                        _FilterDropdownField(
                          hint: LK.selectState.tr,
                          rxValue: controller.selectedState,
                          rxItems: controller.states,
                          prependAll: true,
                          itemStringifier: (e) => (e as dynamic).text as String,
                          mapper: _translateFallback,
                          onChanged: (val) => controller.onStateChanged(val),
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => _FilterDropdownField(
                            hint: LK.selectDistrict.tr,
                            rxValue: controller.selectedDistrict,
                            rxItems: controller.districts,
                            prependAll: true,
                            itemStringifier: (e) =>
                                (e as dynamic).text as String,
                            mapper: _translateFallback,
                            onChanged: (val) =>
                                controller.onDistrictChanged(val),
                            isEnabled: controller.selectedState.value != 'All',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => _FilterDropdownField(
                            hint: LK.selectTaluka.tr,
                            rxValue: controller.selectedTaluka,
                            rxItems: controller.talukas,
                            prependAll: true,
                            itemStringifier: (e) =>
                                (e as dynamic).text as String,
                            mapper: _translateFallback,
                            onChanged: (val) => controller.onTalukaChanged(val),
                            isEnabled:
                                controller.selectedDistrict.value != 'All',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => _FilterDropdownField(
                            hint: 'Select Area',
                            rxValue: controller.selectedArea,
                            rxItems: controller.areas,
                            prependAll: true,
                            itemStringifier: (e) =>
                                (e as dynamic).text as String,
                            mapper: _translateFallback,
                            isEnabled: controller.selectedTaluka.value != 'All',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.educationLabel.tr,
                    icon: Iconsax.teacher_copy,
                    child: _FilterDropdownField(
                      rxValue: controller.selectedEducation,
                      rxItems: controller.dynamicEducations,
                      mapper: _translateFallback,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.occupationLabel.tr,
                    icon: Iconsax.briefcase_copy,
                    child: _FilterDropdownField(
                      rxValue: controller.selectedOccupation,
                      rxItems: controller.dynamicOccupations,
                      mapper: _translateFallback,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldSection(
                    label: LK.incomeRangeLabel.tr,
                    icon: Iconsax.money_3_copy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIncomeTextRow(
                          label: '',
                          fromCtrl: controller.incomeFromCtrl,
                          toCtrl: controller.incomeToCtrl,
                        ),
                        Obx(() {
                          if (controller.incomeError.value.isNotEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                controller.incomeError.value,
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            controller.closeAdvancedFilters();
                            if (controller.incomeError.value.isEmpty &&
                                controller.ageError.value.isEmpty &&
                                controller.heightError.value.isEmpty) {
                              Get.back<void>();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            LK.applyFilters.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.clearFilters(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            LK.clearAll.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.black),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _buildFilterRow({
    required RxString fromRx,
    required RxString toRx,
    required RxString errorRx,
    List<String>? staticItems,
    String Function(String)? mapper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _FilterDropdownField(
                rxValue: fromRx,
                staticItems: staticItems,
                mapper: mapper,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'To',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _FilterDropdownField(
                rxValue: toRx,
                staticItems: staticItems,
                mapper: mapper,
              ),
            ),
          ],
        ),
        Obx(() {
          if (errorRx.value.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                errorRx.value,
                style: TextStyle(color: AppColors.red, fontSize: 12.sp),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildIncomeTextRow({
    required String label,
    required TextEditingController fromCtrl,
    required TextEditingController toCtrl,
  }) {
    return Row(
      children: [
        Expanded(child: _buildIncomeTextField(fromCtrl, '0')),
        SizedBox(width: 12.w),
        Text(
          'To',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _buildIncomeTextField(toCtrl, '999999999')),
      ],
    );
  }

  Widget _buildIncomeTextField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 44.h,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
        ),
      ),
    );
  }
}

class _FilterDropdownField extends StatelessWidget {
  const _FilterDropdownField({
    required this.rxValue,
    this.staticItems,
    this.rxItems,
    this.itemStringifier,
    this.prependAll = false,
    this.onChanged,
    this.mapper,
    this.hint,
    this.isEnabled = true,
  });

  final RxString rxValue;
  final List<String>? staticItems;
  final RxList<dynamic>? rxItems;
  final String Function(dynamic)? itemStringifier;
  final bool prependAll;
  final void Function(String)? onChanged;
  final String Function(String)? mapper;
  final String? hint;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final val = rxValue.value;
      final isEnabledVal = isEnabled;

      List<String> items = [];
      if (staticItems != null) {
        items = List.from(staticItems!);
      } else if (rxItems != null) {
        if (prependAll) items.add('All');
        items.addAll(
          rxItems!.map(
            (e) => itemStringifier != null ? itemStringifier!(e) : e.toString(),
          ),
        );
      }

      if (!items.contains(val) && items.isNotEmpty) {
        items.add(val);
      }

      return Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isEnabledVal
              ? AppColors.white
              : AppColors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isEnabledVal
                ? (val != 'All' && val != 'Any'
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.grey.withValues(alpha: 0.25))
                : AppColors.grey.withValues(alpha: 0.15),
            width: 1.2.w,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            isDense: true,
            isExpanded: true,
            focusColor: AppColors.transparent,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isEnabledVal ? AppColors.primary : AppColors.grey,
              size: 20.sp,
            ),
            items: items.toSet().toList().map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(
                  mapper != null ? mapper!(e) : e,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEnabledVal ? AppColors.black : AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: isEnabledVal
                ? (newVal) {
                    if (newVal != null) {
                      rxValue.value = newVal;
                      onChanged?.call(newVal);
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(12.r),
            dropdownColor: AppColors.white,
            elevation: 8,
            menuMaxHeight: 350,
          ),
        ),
      );
    });
  }
}

String _translateFallback(String val) {
  if (val == 'All') return LK.all.tr;
  if (val == 'Any') return LK.any.tr;
  if (val.contains('Lakh')) {
    return val.replaceAll('Lakh', LK.lakh.tr);
  }
  if (val.contains('Crore')) {
    return val.replaceAll('Crore', LK.crore.tr);
  }
  return val;
}
