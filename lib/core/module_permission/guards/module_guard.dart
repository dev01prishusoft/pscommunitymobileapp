import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/services/module_permission_service.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';

/// GetX Route Middleware to protect screens that require a purchased Samaj module.
/// If user navigates directly or via deep link to an unpurchased module,
/// redirects back to safe route and displays an informative notification.
class ModuleGuard extends GetMiddleware {
  ModuleGuard(
    this.requiredModule, {
    this.redirectRoute = '/home',
    super.priority = 10,
  });

  final AppModule requiredModule;
  final String redirectRoute;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<ModulePermissionService>()) {
      return null;
    }

    final service = ModulePermissionService.to;
    if (!service.isAccessible(requiredModule)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PSDelightToastBar(
          builder: (context) => ToastCard(
            title: 'Access Restricted',
            subtitle:
                'This Samaj has not purchased the ${requiredModule.code} module.',
            isErrorMessage: true,
          ),
        ).show();
      });
      return RouteSettings(name: redirectRoute);
    }

    return null;
  }
}
