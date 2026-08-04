import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/constants/mappers.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_card.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/core/widgets/custom_dropdown.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';

import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/features/member/controllers/find_member_controller.dart';

class FindMemberPage extends StatefulWidget {
  const FindMemberPage({super.key});

  @override
  State<FindMemberPage> createState() => _FindMemberPageState();
}

class _FindMemberPageState extends State<FindMemberPage> {
  final FindMemberController _controller = Get.find<FindMemberController>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
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
                  hintText: LK.searchHint.tr,
                  controller: _searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _searchController.clear();
                      _controller.clearSearch();
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isSearchVisible = false;
                      });
                    } else {
                      _controller.updateSearch(value);
                    }
                  },
                )
              : Text(LK.findMember.tr),
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
                  Get.dialog<void>(const _FindMemberFilterDialog());
                },
              ),
            ],
          ],
        ),
        body: PaginatedListView<Member, FindMemberController>(
          emptyMessage: LK.noMembersFound.tr,
          padding: AppSpacing.pagePadding,
          separatorBuilder: (val, val2) => SizedBox(height: 6.h),
          itemBuilder: (context, index, member) =>
              _FindMemberCard(member: member),
        ),
      ),
    );
  }
}

class _FindMemberCard extends StatelessWidget {
  const _FindMemberCard({required this.member});
  final Member member;

  Widget _buildHeadBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 0.5.w,
        ),
      ),
      child: Text(
        LK.familyHead.tr,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildMarriageBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.pink.withValues(alpha: 0.2),
          width: 0.5.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 10.sp, color: AppColors.pink),
          SizedBox(width: 3.w),
          Text(
            LK.lookingForMarriage.tr,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderAgeBadge() {
    final infoParts = <String>[];
    final genderKey = GenderMapper.getLabelKey(member.gender);
    if (genderKey != null) {
      infoParts.add(genderKey.tr);
    } else if (member.gender.isNotEmpty) {
      infoParts.add(member.gender);
    }
    if (member.age > 0) {
      infoParts.add('${member.age} ${LK.ageYears.tr}');
    }
    final text = infoParts.join(' • ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 0.5.w,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.grey.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildGotraBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.blue.shade50,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.blue.shade100, width: 0.5.w),
      ),
      child: Text(
        '${LK.gotraLabel.tr} ${member.gotra}',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.blue.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String occupationText = member.occupation;
    if (member.companyName != null && member.companyName!.isNotEmpty) {
      occupationText += ' @ ${member.companyName}';
    } else if (member.businessName != null && member.businessName!.isNotEmpty) {
      occupationText += ' @ ${member.businessName}';
    }

    return AppCard(
      elevation: 0.02,
      border: Border.all(
        color: AppColors.grey.withValues(alpha: 0.15),
        width: 1.w,
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: MemberAvatar(
                imageUrl: member.profilePhotoFullUrl,
                gender: member.gender,
                fallbackName: member.name,
                radius: 26.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 8.h,
                    children: [
                      if (member.isHead == true) _buildHeadBadge(),
                      if (member.isLookingforMarriage == true)
                        _buildMarriageBadge(),
                      _buildGenderAgeBadge(),
                      if (member.gotra.isNotEmpty) _buildGotraBadge(),
                    ],
                  ),
                  if (member.occupation.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: 13.sp,
                          color: AppColors.grey.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            occupationText,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (member.area.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13.sp,
                          color: AppColors.grey.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            member.area,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Center(
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FindMemberFilterDialog extends StatefulWidget {
  const _FindMemberFilterDialog();

  @override
  State<_FindMemberFilterDialog> createState() => _FindMemberFilterDialogState();
}

class _FindMemberFilterDialogState extends State<_FindMemberFilterDialog> {
  final controller = Get.find<FindMemberController>();

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
