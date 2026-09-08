import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/home/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/core/models/app_link_model.dart';
import 'package:pscommunitymobileapp/core/models/member_notification.dart';
import 'package:pscommunitymobileapp/core/module_permission/module_permission.dart';
import 'package:pscommunitymobileapp/core/services/check_updated_version.dart';

class MenuItem {
  MenuItem({
    required this.icon,
    required this.labelKey,
    required this.route,
    this.module,
  });
  final IconData icon;
  final String labelKey;
  final String route;
  final AppModule? module;
}

class HomeController extends GetxController with WidgetsBindingObserver {
  final List<MenuItem> _allMenuItems = [
    MenuItem(
      icon: Icons.family_restroom,
      labelKey: LK.family,
      route: AppRouter.familyAreas,
    ),
    MenuItem(
      icon: Icons.person_search,
      labelKey: LK.findMember,
      route: AppRouter.findMember,
    ),
    MenuItem(
      icon: Icons.groups_outlined,
      labelKey: LK.committee,
      route: AppRouter.committees,
    ),
    MenuItem(
      icon: Icons.account_balance_wallet,
      labelKey: LK.payment,
      route: AppRouter.payments,
      module: AppModule.payment,
    ),
    MenuItem(
      icon: Icons.work,
      labelKey: LK.occupationDirectory,
      route: AppRouter.occupationDirectory,
      module: AppModule.occupation,
    ),
    MenuItem(
      icon: Icons.wc,
      labelKey: LK.marriage,
      route: AppRouter.marriage,
      module: AppModule.matrimonial,
    ),
    MenuItem(icon: Icons.share, labelKey: LK.share, route: AppRouter.shareApp),
    MenuItem(
      icon: Icons.info_outline,
      labelKey: LK.samajInfo,
      route: AppRouter.bankDetails,
    ),
    MenuItem(
      icon: Icons.support_agent,
      labelKey: LK.customerSupport,
      route: AppRouter.customerSupport,
    ),
  ];

  /// Returns only the menu items that are permitted/accessible for this member's Samaj.
  List<MenuItem> get menuItems {
    if (!Get.isRegistered<ModulePermissionService>()) {
      return _allMenuItems;
    }
    final permissionService = ModulePermissionService.to;
    return _allMenuItems.where((item) {
      if (item.module == null) return true;
      return permissionService.isAccessible(item.module!);
    }).toList();
  }

  String version = '';
  final RxInt unreadNotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    Get.find<LocalizationService>().fetchLanguages();
    checkAppVersion();
    if (Get.isRegistered<ModulePermissionService>()) {
      Get.find<ModulePermissionService>().fetchMyModules();
    }
    fetchUnreadNotificationCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (Get.context == null) return;
      if (isUpdateSheetOpen && Get.context!.mounted) {
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }
      await checkAppVersion();
      if (Get.isRegistered<ModulePermissionService>()) {
        await Get.find<ModulePermissionService>().fetchMyModules();
      }
      await fetchUnreadNotificationCount();
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      if (Get.isRegistered<ModulePermissionService>()) {
        if (!ModulePermissionService.to.isAccessible(AppModule.dailyNotification)) {
          unreadNotificationCount.value = 0;
          return;
        }
      }
      final apiClient = Get.find<ApiClient>();
      final result = await apiClient.getPaginated<MemberNotification>(
        ApiEndpoints.notifications,
        queryParameters: {'Page': 1, 'PageSize': 1},
        listKey: 'data',
        fromJsonT: (json) =>
            MemberNotification.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess) {
        unreadNotificationCount.value = result.dataOrNull?.unreadCount ?? 0;
      }
    } catch (e) {}
  }

  void changeLocale(LocalizationService loc, String? code) {
    if (code == null) return;
    loc.changeLocale(code.toLowerCase(), '');
  }

  Future<void> checkAppVersion() async {
    if (Get.context == null) return;
    PackageInfo.fromPlatform().then((value) async {
      version = value.version;
      update();
      if (version.isNotEmpty) {
        await Get.find<ShareController>().fetchAppLinks();

        final appLinks = Get.find<ShareController>().appLinks;
        if (appLinks.isNotEmpty) {
          final AppLinkModel data = appLinks.firstWhere(
            (e) => e.appType == (Platform.isAndroid ? 'Android' : 'iOS'),
          );

          if (data.appType.isNotEmpty) {
            final String latestVersion = data.currentVersion;
            final bool forceUpdate = data.appUpdateRequired;
            final String appLink = data.appLink;

            final bool wentForUpdate = await SecureStorageService().getBool(
              LK.wentForUpdate,
            );

            if (!isVersionGreater(latestVersion, version) && wentForUpdate) {
              if (isUpdateSheetOpen && Get.context!.mounted) {
                Navigator.of(Get.context!, rootNavigator: true).pop();
              }
              await SecureStorageService().setBool(LK.wentForUpdate, false);
              if (Get.context!.mounted) {
                PSDelightToastBar(
                  snackbarDuration: const Duration(seconds: 3),
                  builder: (context) => ToastCard(
                    title: LK.appUpdatedSuccessfully.tr,
                    leading: Icons.check_circle,
                  ),
                ).show();
              }
              return;
            }
            if (isVersionGreater(latestVersion, version)) {
              showAppUpdateBottomSheet(
                Get.context!,
                forceUpdate: forceUpdate,
                androidUrl: Platform.isAndroid ? appLink : '',
                iosUrl: Platform.isIOS ? appLink : '',
              );
            }
          }
        }
      }
    });
  }
}
