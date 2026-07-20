import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';

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
      appBar: AppBar(title: Text(LK.occupationDirectory.tr)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppTextField(
                controller: _searchController,
                hint: LK.searchOccupation.tr,
                icon: Iconsax.search_normal_copy,
                onChanged: _controller.search,
                suffixIcon: Obx(
                  () => _controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20.r,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _controller.clearSearch();
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 34.h,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _controller.occupationTypes.length,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                itemBuilder: (context, index) {
                  final type = _controller.occupationTypes[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: _buildFilterChip(type),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 15.h),

          Expanded(
            child: Obx(
              () => AppStateView(
                state: _controller.state.value,
                onRetry: _controller.loadOccupations,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                                      childAspectRatio: 1.2,
                                    ),
                                padding: EdgeInsets.only(bottom: 20.h),
                                itemCount:
                                    _controller.filteredOccupations.length,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(DropdownItem type) {
    final displayName = type.id == 0 ? LK.all.tr : type.text;
    return Obx(() {
      final isSelected =
          _controller.selectedOccupationType.value?.id == type.id;
      return GestureDetector(
        onTap: () {
          _controller.onOccupationTypeChanged(type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.grey.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getChipIcon(displayName),
                size: 14.r,
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
              SizedBox(width: 4.w),
              Text(
                displayName,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.secondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getChipIcon(String text) {
    final lower = text.toLowerCase();
    if (lower == 'all') return Icons.grid_view_rounded;
    if (lower.contains('business')) return Icons.business_center_rounded;
    if (lower.contains('job')) return Icons.work_rounded;
    if (lower.contains('profession')) return Icons.psychology_rounded;
    if (lower.contains('agriculture')) return Icons.agriculture_rounded;
    if (lower.contains('medical') || lower.contains('doctor'))
      return Icons.medical_services_rounded;
    if (lower.contains('school') ||
        lower.contains('education') ||
        lower.contains('teacher'))
      return Icons.school_rounded;
    return Icons.work_rounded;
  }

  Widget _buildOccupationCard(OccupationItem occ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed<void>(
              AppRouter.occupationProfile,
              arguments: {'occupationId': occ.id, 'occupationName': occ.name},
            );
          },
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                fit: BoxFit.contain,
                                placeholder: (context, url) => SizedBox(
                                  height: 25.h,
                                  width: 25.w,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                10.verticalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      occ.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tap to explore',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey.shade600,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
              fontSize: 16.sp,
            ),
          ),
          Text(
            (count == null || count <= 1) ? LK.member.tr : LK.membersCount.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontSize: 12.sp,
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
