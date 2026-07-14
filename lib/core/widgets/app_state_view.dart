import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';

enum AppState { loading, error, empty, data }

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.state,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage,
    this.emptyIcon,
    this.emptyActionButton,
  });
  final AppState state;
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final Widget? emptyActionButton;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case AppState.loading:
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case AppState.error:
        return Center(
          child: AppErrorState(errorMessage: errorMessage, onRetry: onRetry),
        );
      case AppState.empty:
        return Center(
          child: AppEmptyState(
            icon: emptyIcon ?? Icons.search_off_rounded,
            secondaryIcon: emptyIcon,
            title: emptyMessage ?? LK.noResultsFound.tr,
            subtitle: LK.trySelectingDifferentFilters.tr,
            actionButton: emptyActionButton,
          ),
        );
      case AppState.data:
        return child;
    }
  }
}
