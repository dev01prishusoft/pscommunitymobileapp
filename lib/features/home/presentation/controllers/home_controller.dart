import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/features/home/presentation/model/app_link_model.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';
import 'package:pscommunitymobileapp/features/update/check_updated_version.dart';

class MenuItem {
  MenuItem({required this.icon, required this.labelKey, required this.route});
  final IconData icon;
  final String labelKey;
  final String route;
}

class HomeController extends GetxController with WidgetsBindingObserver {
  final List<MenuItem> menuItems = [
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
    ),
    MenuItem(
      icon: Icons.work,
      labelKey: LK.occupationDirectory,
      route: AppRouter.occupationDirectory,
    ),
    MenuItem(
      icon: Icons.wc,
      labelKey: LK.matrimonial,
      route: AppRouter.marriage,
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

  String version = '';
  final RxInt unreadNotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    Get.find<LocalizationService>().fetchLanguages();
    checkAppVersion();
    fetchUnreadNotificationCount();
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null && Get.arguments is Map) {
      final targetRoute = Get.arguments['targetRoute'];
      if (targetRoute != null && targetRoute is String) {
        Get.toNamed<void>(targetRoute);
      }
    }
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
      await fetchUnreadNotificationCount();
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
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
