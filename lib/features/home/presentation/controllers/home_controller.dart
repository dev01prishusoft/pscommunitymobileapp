import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';

class MenuItem {
  MenuItem({required this.icon, required this.labelKey, required this.route});
  final IconData icon;
  final String labelKey;
  final String route;
}

class HomeController extends GetxController {

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.family_restroom, labelKey: LK.family, route: AppRouter.familyAreas),
    MenuItem(icon: Icons.person_search, labelKey: LK.findMember, route: AppRouter.findMember),
    MenuItem(icon: Icons.groups_outlined, labelKey: LK.committee, route: AppRouter.committees),
    MenuItem(icon: Icons.account_balance_wallet, labelKey: LK.payment, route: AppRouter.payments),
    MenuItem(icon: Icons.work, labelKey: LK.occupationDirectory, route: AppRouter.occupationDirectory),
    MenuItem(icon: Icons.wc, labelKey: LK.matrimonial, route: AppRouter.marriage),
    MenuItem(icon: Icons.share, labelKey: LK.share, route: AppRouter.shareApp),
    MenuItem(icon: Icons.info_outline, labelKey: LK.samajInfo, route: AppRouter.samajProfile),
  ];

  @override
  void onInit() {
    super.onInit();
    Get.find<LocalizationService>().fetchLanguages();
  }

  void changeLocale(LocalizationService loc, String? code) {
    if (code == null) return;
    loc.changeLocale(code.toLowerCase(), '');
  }
}
