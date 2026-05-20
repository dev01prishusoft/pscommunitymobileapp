import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';

enum AppState { loading, error, empty, data }

class AppStateView extends StatelessWidget {
  final AppState state;
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final IconData? emptyIcon;

  const AppStateView({
    super.key,
    required this.state,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage,
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case AppState.loading:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case AppState.error:
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: AppColors.destructive,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage ?? LK.somethingWrong.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.foreground,
                          ),
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: onRetry,
                            child: Text(LK.retry.tr),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case AppState.empty:
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AppEmptyState(
                      icon: emptyIcon ?? Icons.search_off_rounded,
                      secondaryIcon: emptyIcon != null ? null : Icons.search,
                      title: emptyMessage ?? LK.noResultsFound.tr,
                      subtitle: LK.trySelectingDifferentFilters.tr,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case AppState.data:
        return child;
    }
  }
}
