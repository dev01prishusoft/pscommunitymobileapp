import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/services/module_permission_service.dart';

/// Declarative widget that conditionally displays [child] if the Samaj has access
/// to [module]. If not accessible, displays [fallback] (defaults to [SizedBox.shrink]).
class ModulePermissionGate extends StatelessWidget {
  const ModulePermissionGate({
    super.key,
    required this.module,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final AppModule module;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = ModulePermissionService.to;
      final accessible = service.isAccessible(module);
      return accessible ? child : fallback;
    });
  }
}

/// Builder widget that provides the accessibility flag to the builder function.
class ModulePermissionBuilder extends StatelessWidget {
  const ModulePermissionBuilder({
    super.key,
    required this.module,
    required this.builder,
  });

  final AppModule module;
  final Widget Function(BuildContext context, bool isAccessible) builder;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = ModulePermissionService.to;
      final accessible = service.isAccessible(module);
      return builder(context, accessible);
    });
  }
}
