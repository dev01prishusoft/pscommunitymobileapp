import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/responsive_helper.dart';
import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/home_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: AppBar(
        actions: [
          _NotificationMenu(),
          AppSpacing.hS,
          _LanguageDropdown(),
          AppSpacing.hL,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppSpacing.vL,
            _HomeHeader(),
            AppSpacing.vL,
            Expanded(
              child: _HomeMenuGrid(controller: Get.find<HomeController>()),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends GetView<SamajController> {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.s,
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
      ),
      child: Obx(() {
        final samaj = controller.samaj.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                samaj?.name ?? LK.samajName.tr,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: samaj?.logoUrl != null && samaj!.logoUrl.isNotEmpty
                    ? CachedImg(
                        url: samaj.logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => _fallbackLogo(),
                      )
                    : _fallbackLogo(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget _fallbackLogo() =>
    Image.asset('assets/images/prishusoft_logo.png', fit: BoxFit.cover);

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = ResponsiveHelper.calculateGridCrossAxisCount(
              context,
              desiredItemWidth: 110.w,
            );
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.menuItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14.h,
                crossAxisSpacing: 14.w,
                childAspectRatio: 0.84,
              ),
              itemBuilder: (context, index) {
                final item = controller.menuItems[index];
                return _MenuCard(item: item);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.12),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            Get.toNamed<void>(item.route)?.then((_) async {
              await Get.find<SamajController>().fetchAll();
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 52.h,
                  width: 52.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 24.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      item.labelKey.tr,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

      return Container(
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCode,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(10.r),
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            items: codes.map((code) {
              return DropdownMenuItem<String>(value: code, child: Text(code));
            }).toList(),
            onChanged: (code) {
              homeController.changeLocale(controller, code);
            },
          ),
        ),
      );
    });
  }
}

class _NotificationMenu extends GetView<HomeController> {
  const _NotificationMenu();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Obx(() {
        final count = controller.unreadNotificationCount.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Iconsax.notification_copy),
            if (count > 0) ...[
              Positioned(
                right: -2,
                top: -2,
                child: Badge(
                  backgroundColor: AppColors.primary,
                  label: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
      onPressed: () {
        Get.toNamed<void>('/notifications')?.then((_) {
          controller.fetchUnreadNotificationCount();
        });
      },
    );
  }
}
