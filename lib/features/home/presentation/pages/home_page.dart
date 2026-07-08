import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

/// [StatefulWidget] so [_scaffoldKey] is created once and stays stable
/// across rebuilds. A [GlobalKey] inside a [StatelessWidget] is recreated
/// on every build, which can cause state loss.
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
    AppRouter.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    Get.find<SamajController>().fetchSamajDetail(updateLanguage: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceVariant,
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navyBlue),
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
            _HomeHeader(),
            AppSpacing.vL,
            Expanded(child: _HomeMenuGrid(controller: Get.find<HomeController>())),
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
      padding: EdgeInsets.only(top: AppSpacing.s, left: AppSpacing.xxl, right: AppSpacing.xxl),
      child: Obx(() {
        final samaj = controller.samaj.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
          children: [
            Expanded(child: _SamajNameText(samaj: samaj)),
            _SamajLogo(samaj: samaj),
          ],
        );
      }),
    );
  }
}

class _SamajNameText extends StatelessWidget {
  const _SamajNameText({required this.samaj});

  final Samaj? samaj;

  @override
  Widget build(BuildContext context) {
    return Text(
      samaj?.name ?? LK.samajName.tr,
      style: AppTextStyles.displaySmall.copyWith(
        color: AppColors.navyBlue,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SamajLogo extends StatelessWidget {
  const _SamajLogo({required this.samaj});

  final Samaj? samaj;
  @override
  Widget build(BuildContext context) {
    final logoUrl = samaj?.logoUrl;
    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child:logoUrl != null && logoUrl.isNotEmpty
          ? CachedImg(
              url: logoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (_, __, ___) => _fallbackLogo(),
            )
          : _fallbackLogo(),)
    );
  }

  Widget _fallbackLogo() =>
      Image.asset('assets/images/prishusoft_logo.png', fit: BoxFit.cover);
}

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: AppSpacing.pHXl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = ResponsiveHelper.calculateGridCrossAxisCount(context, desiredItemWidth: 120);
            return GridView.builder( 
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.menuItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
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
  static final BoxDecoration _cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  static BoxDecoration get cardDecorationWithShadow => _cardDecoration.copyWith(
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.labelKey.tr,
      child: GestureDetector(
        onTap: () => Get.toNamed<void>(item.route),
        child: Container(
          decoration: cardDecorationWithShadow,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: AppSpacing.pM,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 32, color: AppColors.navyBlue),
              ),
              AppSpacing.vM,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.labelKey.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.navyBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
      final String currentCode = controller.currentLocale.value.languageCode.toUpperCase();
      final homeController = Get.find<HomeController>();
      
      List<String> codes = controller.languages
          .map((l) => l.code.toUpperCase())
          .toSet()
          .toList();
          
      if (codes.isEmpty) codes = ['EN', 'GU'];

      final selectedCode = codes.contains(currentCode)
          ? currentCode
          : codes.first;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCode,
            icon: Icon(Icons.language, color: AppColors.navyBlue, size: 18),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.navyBlue,
            ),
            items: codes
                .map(
                  (code) =>
                      DropdownMenuItem(value: code, child: Text(' $code')),
                )  
                .toList(),
            onChanged: (code) => homeController.changeLocale(controller, code),
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
        if (count > 0) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications, color: AppColors.navyBlue, size: 28),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: count > 99 ? BorderRadius.circular(10) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }
        return Icon(Icons.notifications, color: AppColors.navyBlue, size: 28);
      }),
      onPressed: () {
        Get.toNamed<void>('/notifications')?.then((_) {
          controller.fetchUnreadNotificationCount();
        });
      },
    );
  }
}
