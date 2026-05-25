import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/utils/responsive_extensions.dart';

class ResponsiveFormContainer extends StatelessWidget {
  const ResponsiveFormContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.optimalFormWidth,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class AdaptiveBottomSheet {
  AdaptiveBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showHandle = true,
    bool safeKeyboardInset = true,
    double? maxWidth,
    double maxHeightFactor = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final content = Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? (context.isTablet || context.isDesktop ? 600 : double.infinity),
              maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
            ),
            padding: safeKeyboardInset ? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom) : EdgeInsets.zero,
            child: showHandle
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Flexible(child: child),
                    ],
                  )
                : child,
          ),
        );
        return content;
      },
    );
  }
}
