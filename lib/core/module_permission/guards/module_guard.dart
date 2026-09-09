import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/services/module_permission_service.dart';
import 'package:pscommunitymobileapp/core/network/app_config.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';

/// GetX Route Middleware to protect screens that require a purchased Samaj module.
/// If user navigates directly or via deep link to an unpurchased module,
/// redirects back to safe route and displays an informative notification.
class ModuleGuard extends GetMiddleware {
  ModuleGuard(
    this.requiredModule, {
    this.redirectRoute = '/home',
    this.customTitle,
    this.customSubtitle,
    super.priority = 10,
  });

  final AppModule requiredModule;
  final String redirectRoute;
  final String? customTitle;
  final String? customSubtitle;

  @override
  RouteSettings? redirect(String? route) {
    if (kUiReviewMode) return null;

    if (!Get.isRegistered<ModulePermissionService>()) {
      return null;
    }

    final service = ModulePermissionService.to;
    if (!service.isAccessible(requiredModule)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final title = customTitle ?? LK.accessRestricted.tr;
        final subtitle = customSubtitle ??
            LK.moduleAccessRestrictedSubtitle.trParams({
              'module': requiredModule.localizedName,
            });

        PSDelightToastBar(
          builder: (context) => ToastCard(
            title: title,
            subtitle: subtitle,
            isErrorMessage: true,
          ),
        ).show();
      });
      return RouteSettings(name: redirectRoute);
    }

    return null;
  }
}

