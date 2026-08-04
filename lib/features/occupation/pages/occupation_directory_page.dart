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
import 'package:pscommunitymobileapp/features/occupation/controllers/occupation_controller.dart';

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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
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
        await Get.toNamed<void>(
          AppRouter.occupationProfile,
          arguments: {'occupationId': occ.id, 'occupationName': occ.name},
        );
        FocusManager.instance.primaryFocus?.unfocus();
        _controller.loadOccupations(refresh: true);
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
