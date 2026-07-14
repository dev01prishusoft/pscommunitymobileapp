import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class PSDelightToastBar {
  final Duration snackbarDuration;
  final WidgetBuilder builder;
  static OverlayEntry? _activeEntry;

  PSDelightToastBar({
    this.snackbarDuration = const Duration(milliseconds: 3000),
    required this.builder,
  });

  void remove() {
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }
  }

  void show() {
    removeAll();

    final entryKey = GlobalKey<RawDelightToastState>();
    final entry = OverlayEntry(
      builder: (ctx) => RawDelightToast(
        key: entryKey,
        snackbarDuration: snackbarDuration,
        onRemove: remove,
        child: builder.call(ctx),
      ),
    );

    _activeEntry = entry;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;
      final overlayState = Navigator.of(Get.context!).overlay;
      if (overlayState != null) {
        overlayState.insert(entry);
      }
    });
  }

  static void removeAll() {
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }
  }
}

class RawDelightToast extends StatefulWidget {
  final Widget child;
  final Duration snackbarDuration;
  final VoidCallback onRemove;

  const RawDelightToast({
    super.key,
    required this.child,
    required this.snackbarDuration,
    required this.onRemove,
  });

  @override
  State<RawDelightToast> createState() => RawDelightToastState();
}

class RawDelightToastState extends State<RawDelightToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _autoDismissTimer = Timer(widget.snackbarDuration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: null,
      bottom: 70,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.down,
            onDismissed: (_) {
              widget.onRemove();
            },
            child: Material(color: Colors.transparent, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class ToastCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final Color? shadowColor;
  final Function()? onTap;
  final bool isErrorMessage;

  const ToastCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.shadowColor,
    this.trailing,
    this.onTap,
    this.isErrorMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isErrorMessage
              ? [AppColors.primary, AppColors.secondary]
              : [const Color(0xFF1E6C3B), const Color(0xFF0F3E21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isErrorMessage ? AppColors.primary : const Color(0xFF1E6C3B))
                    .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        dense: false,
        leading: Icon(
          leading ??
              (isErrorMessage ? Iconsax.close_circle : Iconsax.tick_circle),
          color: Colors.white,
        ),
        trailing: trailing,
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        onTap: onTap,
      ),
    );
  }
}
