import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';

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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.family.tr,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterSection(),
              SizedBox(height: 24.h),
              _ResultsHeader(),
              SizedBox(height: 5.h),
              Obx(
                () => AppStateView(
                  state: controller.state.value,
                  onRetry: controller.loadAreas,
                  child: controller.areas.isEmpty
                      ? _EmptyState()
                      : Column(
                          children: [
                            _AreasList(areas: controller.areas),
                            if (controller.isNextPageLoading.value)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
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
      ),
    );
  }
}

class _FilterSection extends GetView<FamilyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.filtersExpanded.value =
                  !controller.filtersExpanded.value,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                    SizedBox(width: 8.w),
                    Text(
                      LK.locationFilters.tr,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      controller.filtersExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: controller.filtersExpanded.value
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        children: [
                          Divider(),
                          SizedBox(height: 16.h),
                          _CustomDropdown(
                            hint: LK.selectState.tr,
                            value: controller.selectedState.value,
                            options: controller.states,
                            onChanged: controller.onStateChanged,
                            isLoading: controller.isStatesLoading.value,
                          ),
                          SizedBox(height: 12.h),
                          _CustomDropdown(
                            hint: LK.selectDistrict.tr,
                            value: controller.selectedDistrict.value,
                            options: controller.districts,
                            onChanged: controller.onDistrictChanged,
                            isEnabled: controller.selectedState.value != null,
                            isLoading: controller.isDistrictsLoading.value,
                          ),
                          SizedBox(height: 12.h),
                          _CustomDropdown(
                            hint: LK.selectTaluka.tr,
                            value: controller.selectedTaluka.value,
                            options: controller.talukas,
                            onChanged: controller.onTalukaChanged,
                            isEnabled:
                                controller.selectedDistrict.value != null,
                            isLoading: controller.isTalukasLoading.value,
                          ),
                          if (controller.selectedState.value != null ||
                              controller.selectedDistrict.value != null ||
                              controller.selectedTaluka.value != null) ...[
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: controller.resetFilters,
                                icon: Icon(Icons.refresh, size: 18),
                                label: Text(LK.reset.tr),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends GetView<FamilyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.areas.isEmpty) return SizedBox.shrink();
      return Text(
        LK.totalAreasLabel.trParams({
          'taluka': controller.selectedTaluka.value?.text ?? 'All',
          'count': controller.areas.length.toString(),
        }),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
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
      physics: NeverScrollableScrollPhysics(),
      itemCount: areas.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final area = areas[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${area.title} (${area.location})',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              '${area.members} ${LK.membersCount.tr}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '|',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.border,
                                ),
                              ),
                            ),
                            Text(
                              '${area.families} ${LK.familiesCount.tr}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.map_outlined,
      secondaryIcon: Icons.location_on,
      title: LK.noAreasFound.tr,
      subtitle: LK.trySelectingDifferentFilters.tr,
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
    final opacity = isEnabled ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DropdownItem>(
            value: (value != null && options.any((o) => o.id == value!.id))
                ? options.firstWhere((o) => o.id == value!.id)
                : null,
            hint: Text(
              hint,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground.withValues(alpha: 0.8),
              ),
            ),
            isExpanded: true,
            icon: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.mutedForeground,
                  ),
            items: options.isEmpty
                ? null
                : options.map((option) {
                    return DropdownMenuItem<DropdownItem>(
                      value: option,
                      child: Text(
                        option.text,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    );
                  }).toList(),
            onChanged: isEnabled ? onChanged : null,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: AppColors.white,
            elevation: 8,
            menuMaxHeight: 350,
          ),
        ),
      ),
    );
  }
}
