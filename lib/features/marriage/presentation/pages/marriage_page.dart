import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';

class MarriagePage extends GetView<MarriageController> {
  const MarriagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.marriage.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return Padding(
          padding: AppSpacing.pL,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                label: LK.unmarriedMale.tr,
                                count: controller.unmarriedMaleCount.toString(),
                                icon: Icons.group,
                                iconColor: AppColors.blue,
                                textColor: AppColors.blue,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildSummaryCard(
                                label: LK.unmarriedFemale.tr,
                                count: controller.unmarriedFemaleCount.toString(),
                                icon: Icons.person,
                                iconColor: Colors.pink,
                                textColor: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Text(
                                  LK.showLabel.tr,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Flexible(
                                  child: Text(
                                    LK.lookingForMarriage.tr,
                                    style: AppTextStyles.labelSmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Obx(
                                  () => SizedBox(
                                    height: 24.h,
                                    width: 36.w,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Switch(
                                        value:
                                            controller.lookingForMarriage.value,
                                        onChanged: (val) {
                                          controller.lookingForMarriage.value =
                                              val;
                                        },
                                        activeThumbColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  LK.gender.tr,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedGender,
                                    staticItems: ['All', 'Male', 'Female'],
                                    mapper: (e) {
                                      if (e == 'All') return LK.all.tr;
                                      final key = GenderMapper.getLabelKey(e);
                                      return key != null ? key.tr : e;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: AppSpacing.pL,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.searchTextController,
                              onChanged: (val) {
                                controller.searchQuery.value = val;
                              },
                              decoration: InputDecoration(
                                hintText: LK.searchByFirstNameHint.tr,
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: Obx(
                                  () => controller.searchQuery.value.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.close),
                                          tooltip: LK.clearAll.tr,
                                          onPressed: () {
                                            controller.searchTextController.clear();
                                            controller.searchQuery.value = '';
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        )
                                      : SizedBox.shrink(),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => InkWell(
                              onTap: () => controller.toggleAdvancedFilters(),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: _dropdownDecoration().copyWith(
                                  color: controller.isAdvancedFiltersOpen.value
                                      ? AppColors.primary
                                      : AppColors.white,
                                ),
                                child: Icon(
                                  Icons.tune,
                                  size: 20,
                                  color: controller.isAdvancedFiltersOpen.value
                                      ? AppColors.white
                                      : AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.state.value == AppState.data) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == controller.filteredMembers.length) {
                        return controller.isNextPageLoading.value 
                            ? Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                            : SizedBox.shrink();
                      }
                      return _buildMemberCard(
                        controller.filteredMembers[index],
                      );
                    }, childCount: controller.filteredMembers.length + (controller.hasMore.value ? 1 : 0)),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: AppStateView(
                        state: controller.state.value,
                        emptyMessage: LK.noMatchesFound.tr,
                        child: SizedBox.shrink(),
                      ),
                    ),
                  );
                }
              }),
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),
          Obx(
            () => controller.isAdvancedFiltersOpen.value
                ? GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.isAdvancedFiltersOpen.value = false;
                    },
                    child: Container(
                      color: AppColors.black26,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : SizedBox.shrink(),
          ),

          Obx(
            () => AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: controller.isAdvancedFiltersOpen.value
                  ? 0
                  : -MediaQuery.of(context).size.height * 1.5,
              left: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85 -
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tune, color: AppColors.primary),
                            SizedBox(width: 8.w),
                            Text(
                              LK.advancedFilters.tr,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.close),
                              tooltip: LK.cancel.tr,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                controller.isAdvancedFiltersOpen.value = false;
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: AppSpacing.pL,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilterRow(
                                label: LK.ageRangeLabel.tr,
                                fromRx: controller.selectedAgeFrom,
                                toRx: controller.selectedAgeTo,
                                errorRx: controller.ageError,
                                staticItems: controller.ages,
                              ),
                              SizedBox(height: 12.h),
                              _buildFilterRow(
                                label: LK.heightRangeLabel.tr,
                                fromRx: controller.selectedHeightFrom,
                                toRx: controller.selectedHeightTo,
                                errorRx: controller.heightError,
                                staticItems: controller.heights,
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(
                                      LK.gotraLabel.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdownField(
                                      rxValue: controller.selectedGotra,
                                      rxItems: controller.dynamicGotras,
                                      mapper: _translateFallback,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Obx(
                                    () => Checkbox(
                                      value: controller.excludeSameGotra.value,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) =>
                                          controller.excludeSameGotra.value =
                                              val!,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      LK.excludeSameGotra.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(
                                      LK.maritalStatusLabel.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdownField(
                                      rxValue: controller.selectedMaritalStatus,
                                      staticItems: controller.maritalStatuses,
                                      mapper: (val) {
                                        if (val == 'All') return LK.all.tr;
                                        final key =
                                            MaritalStatusMapper.getLabelKey(
                                              val,
                                            );
                                        return key != null ? key.tr : val;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 100.w),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        LK.residenceLabel.tr,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 70.w,
                                              child: Text(
                                                LK.stateLabel.tr,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: _buildDropdownField(
                                                rxValue:
                                                    controller.selectedState,
                                                rxItems: controller.states,
                                                prependAll: true,
                                                itemStringifier: (e) =>
                                                    (e as dynamic).text
                                                        as String,
                                                mapper: _translateFallback,
                                                onChanged: (val) => controller
                                                    .onStateChanged(val),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 70.w,
                                              child: Text(
                                                LK.districtLabel.tr,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: _buildDropdownField(
                                                rxValue:
                                                    controller.selectedDistrict,
                                                rxItems: controller.districts,
                                                prependAll: true,
                                                itemStringifier: (e) =>
                                                    (e as dynamic).text
                                                        as String,
                                                mapper: _translateFallback,
                                                onChanged: (val) => controller
                                                    .onDistrictChanged(val),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 70.w,
                                              child: Text(
                                                LK.talukaLabel.tr,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: _buildDropdownField(
                                                rxValue:
                                                    controller.selectedTaluka,
                                                rxItems: controller.talukas,
                                                prependAll: true,
                                                itemStringifier: (e) =>
                                                    (e as dynamic).text
                                                        as String,
                                                mapper: _translateFallback,
                                                onChanged: (val) => controller
                                                    .onTalukaChanged(val),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 70.w,
                                              child: Text(
                                                LK.areaLabel.tr,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: _buildDropdownField(
                                                rxValue:
                                                    controller.selectedArea,
                                                rxItems: controller.areas,
                                                prependAll: true,
                                                itemStringifier: (e) =>
                                                    (e as dynamic).text
                                                        as String,
                                                mapper: _translateFallback,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(
                                      LK.educationLabel.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdownField(
                                      rxValue: controller.selectedEducation,
                                      rxItems: controller.dynamicEducations,
                                      mapper: _translateFallback,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(
                                      LK.occupationLabel.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDropdownField(
                                      rxValue: controller.selectedOccupation,
                                      rxItems: controller.dynamicOccupations,
                                      mapper: _translateFallback,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _buildIncomeTextRow(
                                label: LK.incomeRangeLabel.tr,
                                fromCtrl: controller.incomeFromCtrl,
                                toCtrl: controller.incomeToCtrl,
                              ),
                              Obx(() {
                                if (controller.incomeError.value.isNotEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      controller.incomeError.value,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              }),
                              SizedBox(height: 24.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        controller.closeAdvancedFilters();
                                      },
                                      child: Text(LK.applyFilters.tr),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          controller.clearFilters(),
                                      child: Text(LK.clearAll.tr),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  BoxDecoration _dropdownDecoration() => BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
    borderRadius: BorderRadius.circular(8),
  );

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  count,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: textColor,
                    height: 1.2.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return _MarriageMemberCard(member: member);
  }
}

class _MarriageMemberCard extends StatelessWidget {
  const _MarriageMemberCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final infoParts = <String>[];
    if (member.age > 0) infoParts.add('${member.age} ${LK.ageYears.tr}');
    if (member.occupation.isNotEmpty) infoParts.add(member.occupation);
    if (member.gotra.isNotEmpty) infoParts.add(member.gotra);
    final infoString = infoParts.join(' | ');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: AppSpacing.pL,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberAvatar(
              imageUrl: member.profilePhotoFullUrl,
              gender: member.gender,
              fallbackName: member.name,
              radius: 30.r,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  if (infoString.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      infoString,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                  if (member.area.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            member.area,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
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
                        LK.lookingForMarriage.tr,
                        style: AppTextStyles.bodySmall,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        (member.isLookingforMarriage == true)
                            ? LK.yes.tr
                            : LK.no.tr,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: (member.isLookingforMarriage == true)
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                      Spacer(),
                      OutlinedButton(
                        onPressed: () => Get.toNamed<void>(
                          AppRouter.memberProfile,
                          arguments: {'memberId': member.memberId},
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(LK.view.tr, style: AppTextStyles.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension MarriagePageFilters on MarriagePage {
  Widget _buildFilterRow({
    required String label,
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
            SizedBox(
              width: 100.w,
              child: Text(label, style: AppTextStyles.bodySmall),
            ),
            Expanded(
              child: _buildDropdownField(
                rxValue: fromRx,
                staticItems: staticItems,
                mapper: mapper,
              ),
            ),
            SizedBox(width: 8.w),
            Text('To', style: AppTextStyles.bodySmall),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildDropdownField(
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
              padding: EdgeInsets.only(top: 4),
              child: Text(
                errorRx.value,
                style: TextStyle(color: Colors.red, fontSize: 12.sp),
              ),
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildDropdownField({
    required RxString rxValue,
    List<String>? staticItems,
    RxList<dynamic>? rxItems,
    String Function(dynamic)? itemStringifier,
    bool prependAll = false,
    bool prependAny = false,
    void Function(String)? onChanged,
    String Function(String)? mapper,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: _dropdownDecoration(),
      child: DropdownButtonHideUnderline(
        child: Obx(() {
          final val = rxValue.value;
          List<String> items = [];
          if (staticItems != null) {
            items = List.from(staticItems);
          } else if (rxItems != null) {
            if (prependAll) items.add('All');
            if (prependAny) items.add('Any');
            items.addAll(
              rxItems.map(
                (e) =>
                    itemStringifier != null ? itemStringifier(e) : e.toString(),
              ),
            );
          }

          if (!items.contains(val) && items.isNotEmpty) {
            items.add(val);
          }

          return DropdownButton<String>(
            value: val,
            isDense: true,
            isExpanded: true,
            focusColor: AppColors.transparent,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.foreground,
            ),
            icon: Icon(Icons.arrow_drop_down, size: 20),
            items: items.toSet().toList().map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  mapper != null ? mapper(e) : e,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newVal) {
              if (newVal != null) {
                rxValue.value = newVal;
                onChanged?.call(newVal);
              }
            },
          );
        }),
      ),
    );
  }
  Widget _buildIncomeTextRow({
    required String label,
    required TextEditingController fromCtrl,
    required TextEditingController toCtrl,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100.w,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: _buildIncomeTextField(fromCtrl, '0'),
        ),
        SizedBox(width: 8.w),
        Text('To', style: AppTextStyles.bodySmall),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildIncomeTextField(toCtrl, '999999999'),
        ),
      ],
    );
  }

  Widget _buildIncomeTextField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 36.h,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.foreground,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // We rely on standard theme borders instead of custom container
        ),
      ),
    );
  }
}
