import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/network/app_config.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/module_permission/module_permission.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_webview_page.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';

import 'package:pscommunitymobileapp/features/advertisement/controllers/advertisement_controller.dart';
import 'package:pscommunitymobileapp/features/advertisement/models/ad_placement.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/ad_placement_slot.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/advertisement_card.dart';
import 'package:pscommunitymobileapp/features/home/controllers/home_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/member/pages/added_members_list_page.dart';
import 'package:pscommunitymobileapp/features/events/pages/events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _selectedBottomNavIndex = 0;
  bool _isQuickAccessExpanded = false;
  late final DrawerUserController _drawerUserController;

  @override
  void initState() {
    super.initState();
    _drawerUserController = Get.put(DrawerUserController(), permanent: true);
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().fetchPlacementAds(
        AdPlacement.homeBottom,
        limit: 5,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppRouter.routeObserver.subscribe(
      this,
      ModalRoute.of(context) as PageRoute,
    );
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    Get.find<SamajController>().fetchSamajDetail(updateLanguage: false);
    _drawerUserController.fetchUser();
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().fetchPlacementAds(
        AdPlacement.homeTop,
      );
      Get.find<AdvertisementController>().fetchPlacementAds(
        AdPlacement.homeBottom,
      );
    }
    if (mounted) {
      setState(() {
        _isQuickAccessExpanded = false;
      });
    }
  }

  Widget _buildFallbackLogoSmall() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.account_balance_rounded,
          color: AppColors.primary,
          size: 18.sp,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthState authState) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          LK.logout.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(LK.logoutConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 120.w,
            child: AppPrimaryButton(
              text: LK.logout.tr,
              height: 45.h,
              color: AppColors.primary,
              onPressed: () {
                Get.back<void>();
                authState.logoutAndRedirect();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthState authState) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          LK.deleteAccount.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(LK.deleteAccountConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              Get.back<void>();
              authState.deleteAccountAndRedirect();
              PSDelightToastBar(
                snackbarDuration: const Duration(seconds: 3),
                builder: (context) => ToastCard(
                  title: LK.accountDeleted.tr,
                  subtitle: LK.accountDeletedBody.tr,
                ),
              ).show();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: Size(120.w, 45.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              LK.deleteAccount.tr,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final samajController = Get.find<SamajController>();
    return Obx(() {
      final member = _drawerUserController.member.value;
      final isLoading = _drawerUserController.isLoading.value;
      final userPic = member?.profilePhotoFullUrl;
      final logoUrl = userPic?.isNotEmpty == true
          ? userPic
          : samajController.samaj.value?.logoUrl;
      final name = member != null
          ? '${member.firstName} ${member.lastName}'.trim()
          : (samajController.samaj.value?.name ?? LK.samajName.tr);
      final subtitle = member?.mobileNo?.isNotEmpty == true
          ? member!.mobileNo!
          : (member?.emailAddress?.isNotEmpty == true
                ? member!.emailAddress!
                : (samajController.samaj.value?.name ?? 'Member'));

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed<void>(AppRouter.editProfile)?.then((_) {
            _drawerUserController.fetchUser();
          }),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              // Always primary color background
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(58.r),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (logoUrl != null && logoUrl.isNotEmpty
                              ? CachedImg(
                                  url: logoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    FallBackImage,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(FallBackImage, fit: BoxFit.cover)),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.user_edit_copy,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    final validItems = items.where((widget) => widget is! SizedBox).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: validItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.6,
                color: Colors.grey.withValues(alpha: 0.12),
                indent: 54.w,
              ),
              itemBuilder: (context, index) => validItems[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsView(BuildContext context) {
    final authState = Get.find<AuthState>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await _drawerUserController.fetchUser();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          children: [
            // Top Profile Card from Drawer (Solid Primary Color Background)
            _buildProfileCard(context),

            SizedBox(height: 16.h),

            // 1. Navigation & Services (matching drawer list, without Home, Edit Profile, Advertisement)
            _buildSettingsGroup(
              title: 'Navigation & Services'.tr,
              items: [
                _SettingsTile(
                  icon: Iconsax.search_normal_copy,
                  title: LK.findMember.tr,
                  onTap: () => Get.toNamed<void>(AppRouter.findMember),
                ),
                if (!Get.isRegistered<ModulePermissionService>() ||
                    ModulePermissionService.to.isAccessible(
                      AppModule.matrimonial,
                    ))
                  _SettingsTile(
                    icon: Icons.wc_rounded,
                    title: LK.marriage.tr,
                    onTap: () => Get.toNamed<void>(AppRouter.marriage),
                  ),
                _SettingsTile(
                  icon: Iconsax.buildings_copy,
                  title: LK.samajSansthas.tr,
                  onTap: () => Get.toNamed<void>(AppRouter.samajSansthas),
                ),
                _SettingsTile(
                  icon: Iconsax.user_add_copy,
                  title: LK.addFamilyMember.tr,
                  onTap: () => Get.toNamed<void>(AppRouter.addFamilyMember),
                ),
                _SettingsTile(
                  icon: Iconsax.people_copy,
                  title: LK.addedMembers.tr,
                  onTap: () {
                    setState(() {
                      _selectedBottomNavIndex = 1;
                    });
                  },
                ),
                _SettingsTile(
                  icon: Iconsax.calendar_copy,
                  title: LK.events_title.tr,
                  onTap: () {
                    setState(() {
                      _selectedBottomNavIndex = 2;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // 2. Account Actions
            _buildSettingsGroup(
              title: 'Account Actions'.tr,
              items: [
                _SettingsTile(
                  icon: Iconsax.user_remove_copy,
                  title: LK.deleteAccount.tr,
                  iconColor: const Color(0xFFDC2626),
                  iconBgColor: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFDC2626),
                  showChevron: false,
                  onTap: () => _showDeleteAccountDialog(context, authState),
                ),
                _SettingsTile(
                  icon: Iconsax.logout_1_copy,
                  title: LK.logout.tr,
                  iconColor: const Color(0xFFDC2626),
                  iconBgColor: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFDC2626),
                  showChevron: false,
                  onTap: () => _showLogoutDialog(context, authState),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // App Version Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 20.r,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                SizedBox(width: 8.w),
                FutureBuilder<String>(
                  future: PackageInfo.fromPlatform().then((p) => p.version),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'version ${snapshot.data}',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Privacy Policy • Terms & Conditions links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Get.to<void>(
                    () => AppWebViewPage(
                      title: LK.privacyPolicy.tr,
                      url: AppEnvironment.I.privacyPolicyUrl,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      LK.privacyPolicy.tr,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.to<void>(
                    () => AppWebViewPage(
                      title: LK.termsAndConditions.tr,
                      url: AppEnvironment.I.termsAndConditionsUrl,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      LK.termsAndConditions.tr,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait([
          Get.find<SamajController>().fetchAll(),
          if (Get.isRegistered<ModulePermissionService>())
            Get.find<ModulePermissionService>().fetchMyModules(),
          Get.find<HomeController>().fetchUnreadNotificationCount(),
          if (Get.isRegistered<AdvertisementController>()) ...[
            Get.find<AdvertisementController>().fetchPlacementAds(
              AdPlacement.homeTop,
              limit: 5,
              forceRefresh: true,
            ),
            Get.find<AdvertisementController>().fetchPlacementAds(
              AdPlacement.homeBottom,
              limit: 5,
              forceRefresh: true,
            ),
          ],
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            // 1. Top Advertisement Banner (exact same 130.h height and 10.w padding)
            const AdPlacementSlot(
              placement: AdPlacement.homeTop,
              layout: AdLayout.banner,
              limit: 5,
              height: 130,
            ),

            SizedBox(height: 16.h),

            // 2. Quick Access Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() {
                final _ = Get.find<LocalizationService>().currentLocale.value;
                return Text(
                  LK.quickAccess.tr,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B2559),
                  ),
                );
              }),
            ),

            SizedBox(height: 12.h),

            // 3. 4*2 Menu Grid
            _buildQuickAccessGrid(context),

            Obx(() => SizedBox(height: _hasHomeBottomAd() ? 150.h : 24.h)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSamajAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 16.w,
      title: Obx(() {
        final samaj = Get.find<SamajController>().samaj.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.r),
                child: samaj?.logoUrl != null && samaj!.logoUrl.isNotEmpty
                    ? CachedImg(
                        url: samaj.logoUrl,
                        width: 36.r,
                        height: 36.r,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _buildFallbackLogoSmall(),
                      )
                    : _buildFallbackLogoSmall(),
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                samaj?.name ?? LK.samajName.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B2559),
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
      actions: [
        const _NotificationMenu(),
        SizedBox(width: 4.w),
        const _LanguageDropdown(),
        SizedBox(width: 16.w),
      ],
    );
  }

  bool _hasHomeBottomAd() {
    if (Get.isRegistered<ModulePermissionService>()) {
      if (!ModulePermissionService.to.isAccessible(AppModule.advertisement)) {
        return false;
      }
    }
    if (!Get.isRegistered<AdvertisementController>()) {
      return false;
    }
    return Get.find<AdvertisementController>()
        .getAds(AdPlacement.homeBottom)
        .isNotEmpty;
  }

  Widget? _buildHomeBottomAdFab() {
    return Obx(() {
      if (!_hasHomeBottomAd()) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: double.infinity,
        child: AdPlacementSlot(
          placement: AdPlacement.homeBottom,
          layout: AdLayout.banner,
          height: 130,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedBottomNavIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedBottomNavIndex != 0) {
          setState(() {
            _selectedBottomNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: (_selectedBottomNavIndex == 0 || _selectedBottomNavIndex == 3)
            ? _buildSamajAppBar()
            : null,
        body: SafeArea(
          top: _selectedBottomNavIndex == 0 || _selectedBottomNavIndex == 3,
          child: IndexedStack(
            index: _selectedBottomNavIndex,
            children: [
              _buildHomeView(context),
              const AddedMembersListPage(),
              const EventsPage(),
              _buildSettingsView(context),
            ],
          ),
        ),
        floatingActionButton: _selectedBottomNavIndex == 0
            ? _buildHomeBottomAdFab()
            : null,
        floatingActionButtonLocation:
            const _FullWidthDockedFloatingActionButtonLocation(),
        bottomNavigationBar: Obx(() {
          final _ = Get.find<LocalizationService>().currentLocale.value;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _selectedBottomNavIndex,
                onTap: (index) {
                  setState(() {
                    if (index != _selectedBottomNavIndex) {
                      _isQuickAccessExpanded = false;
                    }
                    _selectedBottomNavIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedFontSize: 11.5.sp,
                unselectedFontSize: 11.sp,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5.sp,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.home_2_copy, size: 22.sp),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.home_2, size: 22.sp),
                    ),
                    label: LK.home.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.people_copy, size: 22.sp),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.people, size: 22.sp),
                    ),
                    label: LK.addedMembers.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.calendar_copy, size: 22.sp),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.calendar, size: 22.sp),
                    ),
                    label: LK.events_title.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.setting_2_copy, size: 22.sp),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Icon(Iconsax.setting_2, size: 22.sp),
                    ),
                    label: LK.setting.tr,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return Obx(() {
      final _ = Get.find<LocalizationService>().currentLocale.value;
      final hasHomeBottomAd = _hasHomeBottomAd();

      final List<_QuickAccessItem> allItems = [
        _QuickAccessItem(
          label: LK.family.tr,
          icon: Icons.family_restroom_outlined,
          onTap: () => Get.toNamed<void>(AppRouter.familyAreas),
        ),
        _QuickAccessItem(
          label: LK.findMember.tr,
          icon: Iconsax.search_normal_copy,
          onTap: () => Get.toNamed<void>(AppRouter.findMember),
        ),
        _QuickAccessItem(
          label: LK.committee.tr,
          icon: Icons.group_outlined,
          onTap: () => Get.toNamed<void>(AppRouter.committees),
        ),
        _QuickAccessItem(
          label: LK.payments.tr,
          icon: Iconsax.wallet_2_copy,
          onTap: () => Get.toNamed<void>(AppRouter.payments),
        ),
        _QuickAccessItem(
          label: LK.occupationDirectory.tr,
          icon: Iconsax.briefcase_copy,
          onTap: () => Get.toNamed<void>(AppRouter.occupationDirectory),
        ),
        _QuickAccessItem(
          label: LK.marriage.tr,
          icon: Icons.wc_outlined,
          onTap: () => Get.toNamed<void>(AppRouter.marriage),
        ),
        _QuickAccessItem(
          label: LK.events_title.tr,
          icon: Iconsax.calendar_copy,
          onTap: () {
            setState(() {
              _selectedBottomNavIndex = 2;
            });
          },
        ),
        _QuickAccessItem(
          label: LK.share.tr,
          icon: Iconsax.share_copy,
          onTap: () => Get.toNamed<void>(AppRouter.shareApp),
        ),
        _QuickAccessItem(
          label: LK.samajInfo.tr,
          icon: Iconsax.info_circle_copy,
          onTap: () => Get.toNamed<void>(AppRouter.bankDetails),
        ),
        _QuickAccessItem(
          label: LK.customerSupport.tr,
          icon: Iconsax.call_calling_copy,
          onTap: () => Get.toNamed<void>(AppRouter.customerSupport),
        ),
      ];

      List<_QuickAccessItem> currentItems;

      if (!hasHomeBottomAd) {
        // When there is no home-bottom advertisement, show all menu items by default without More/Less option
        currentItems = allItems;
      } else {
        // When home-bottom advertisement is present, show 7 items + More (collapsed) or all items + Less (expanded)
        final moreItem = _QuickAccessItem(
          label: LK.more.tr,
          icon: Iconsax.category_copy,
          onTap: () {
            setState(() {
              _isQuickAccessExpanded = true;
            });
          },
        );

        final lessItem = _QuickAccessItem(
          label: LK.less.tr,
          icon: Iconsax.arrow_up_2_copy,
          onTap: () {
            setState(() {
              _isQuickAccessExpanded = false;
            });
          },
        );

        final collapsedItems = [...allItems.take(7), moreItem];

        final expandedItems = [...allItems, lessItem];

        currentItems = _isQuickAccessExpanded ? expandedItems : collapsedItems;
      }

      return AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 2.w,
              childAspectRatio: 0.80,
            ),
            itemBuilder: (context, index) {
              final item = currentItems[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            size: 22.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        height: 30.h,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? textColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.iconBgColor,
    this.textColor,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconBgColor =
        iconBgColor ?? AppColors.primary.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 19.sp, color: effectiveIconColor),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: const Color(0xFF94A3B8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _LanguageDropdown extends GetView<LocalizationService> {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentCode = controller.currentLocale.value.languageCode
          .toUpperCase();
      final homeController = Get.find<HomeController>();

      List<String> codes = controller.languages
          .map((e) => e.code.toUpperCase())
          .toSet()
          .toList();

      if (codes.isEmpty) {
        codes = ['EN', 'GU'];
      }

      final selectedCode = codes.contains(currentCode)
          ? currentCode
          : codes.first;

      return PopupMenuButton<String>(
        initialValue: selectedCode,
        onSelected: (code) {
          homeController.changeLocale(controller, code);
        },
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
        offset: const Offset(0, 45),
        child: Container(
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedCode,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 16.sp,
              ),
            ],
          ),
        ),
        itemBuilder: (context) {
          return codes.map((code) {
            return PopupMenuItem<String>(
              value: code,
              child: Text(
                code,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            );
          }).toList();
        },
      );
    });
  }
}

class _NotificationMenu extends GetView<HomeController> {
  const _NotificationMenu();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.isRegistered<ModulePermissionService>()) {
        final hasAccess = ModulePermissionService.to.isAccessible(
          AppModule.dailyNotification,
        );
        if (!hasAccess) {
          return const SizedBox.shrink();
        }
      }

      final count = controller.unreadNotificationCount.value;
      return IconButton(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Iconsax.notification_bing_copy,
              color: const Color(0xFF1E293B),
              size: 23.sp,
            ),
            if (count > 0) ...[
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: EdgeInsets.all(count > 9 ? 2.5.r : 3.5.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 14.r, minHeight: 14.r),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        onPressed: () {
          Get.toNamed<void>(AppRouter.notifications)?.then((_) {
            controller.fetchUnreadNotificationCount();
          });
        },
      );
    });
  }
}

class _FullWidthDockedFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _FullWidthDockedFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    if (scaffoldGeometry.floatingActionButtonSize.isEmpty ||
        scaffoldGeometry.floatingActionButtonSize.height <= 0) {
      return const Offset(0, -2000);
    }

    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;

    double bottomY = scaffoldGeometry.contentBottom;
    if (scaffoldGeometry.bottomSheetSize.height > 0.0) {
      bottomY =
          scaffoldGeometry.scaffoldSize.height -
          scaffoldGeometry.bottomSheetSize.height;
    }

    final double fabY =
        bottomY - scaffoldGeometry.floatingActionButtonSize.height;
    return Offset(fabX, fabY);
  }
}
