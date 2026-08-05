import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_card.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/core/widgets/custom_dropdown.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';

import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/features/occupation/controllers/occupation_controller.dart';

class OccupationProfilePage extends StatefulWidget {
  const OccupationProfilePage({super.key});

  @override
  State<OccupationProfilePage> createState() => _OccupationProfilePageState();
}

class _OccupationProfilePageState extends State<OccupationProfilePage> {
  final controller = Get.find<OccupationController>();
  int _occupationId = 0;
  String _occupationName = '';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('occupationId')) {
      _occupationId = args['occupationId'] as int;
      _occupationName =
          (args['occupationName'] as String?) ?? LK.occupationProfile.tr;

      controller.activeOccupationId.value = _occupationId;
      controller.memberSearchQuery.value = '';
      controller.loadOccupationMembers(_occupationId, refresh: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadOccupationMembers(_occupationId, refresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    controller.clearMemberSearch();
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
                    controller.clearMemberSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  },
                hintText: LK.searchByNameHint.tr,
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchController.clear();
                    controller.clearMemberSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  } else {
                    controller.searchMembers(value);
                  }
                },
              )
            : Text(_occupationName.tr),
        actions: [
          if (!_isSearchVisible) ...[
            IconButton(
              icon: const Icon(Iconsax.search_normal_copy),
              onPressed: () {
                setState(() {
                  _isSearchVisible = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.filter_search_copy),
              tooltip: LK.locationFilters.tr,
              onPressed: () {
                Get.dialog<void>(const _OccupationFilterDialog());
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => AppStateView(
                  state: controller.membersState.value,
                  onRetry: () =>
                      controller.loadOccupationMembers(_occupationId),
                  child: RefreshIndicator(
                    onRefresh: () => controller.loadOccupationMembers(
                      _occupationId,
                      refresh: true,
                    ),
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          controller.occupationMembers.length +
                          (controller.hasMoreMembers.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.occupationMembers.length) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return _OccupationMemberCard(
                          member: controller.occupationMembers[index],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupationMemberCard extends StatelessWidget {
  const _OccupationMemberCard({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 5.h),
      elevation: 0.02,
      border: Border.all(
        color: AppColors.grey.withValues(alpha: 0.12),
        width: 1.w,
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed<void>(
          AppRouter.frompageOccupation,
          arguments: {'memberId': member.memberId},
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                Text(
                  member.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (member.occupationAreaName != null &&
                        member.occupationAreaName!.isNotEmpty ||
                    member.occupationTalukaName != null &&
                        member.occupationTalukaName!.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.r,
                        color: AppColors.grey.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "${member.occupationAreaName}, ${member.occupationTalukaName}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.sfBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccupationFilterDialog extends StatefulWidget {
  const _OccupationFilterDialog();

  @override
  State<_OccupationFilterDialog> createState() =>
      _OccupationFilterDialogState();
}

class _OccupationFilterDialogState extends State<_OccupationFilterDialog> {
  final controller = Get.find<OccupationController>();

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
