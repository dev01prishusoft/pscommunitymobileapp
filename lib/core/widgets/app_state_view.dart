import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';

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
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppErrorState(errorMessage: errorMessage, onRetry: onRetry),
        );
      case AppState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppEmptyState(
              icon: emptyIcon ?? Icons.search_off_rounded,
              secondaryIcon: emptyIcon != null ? null : Icons.search,
              title: emptyMessage ?? LK.noResultsFound.tr,
              subtitle: LK.trySelectingDifferentFilters.tr,
            ),
          ),
        );
      case AppState.data:
        return child;
    }
  }
}
