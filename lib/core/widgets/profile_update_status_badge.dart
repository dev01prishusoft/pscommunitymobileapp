import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';

class ProfileUpdateStatusBadge extends StatefulWidget {
  const ProfileUpdateStatusBadge({
    super.key,
    required this.status,
    this.showValue = true,
  });
  final ProfileUpdateStatus status;
  final bool showValue;

  @override
  State<ProfileUpdateStatusBadge> createState() =>
      _ProfileUpdateStatusBadgeState();
}

class _ProfileUpdateStatusBadgeState extends State<ProfileUpdateStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status.isApproved) return const SizedBox.shrink();

    final isRejected = widget.status.isRejected;
    final baseColor = isRejected ? AppColors.red : AppColors.orange;
    final bgColor = isRejected
        ? AppColors.red.withValues(alpha: 0.08)
        : AppColors.orange.withValues(alpha: 0.08);

    final statusText = widget.showValue
        ? '${isRejected ? LK.rejected.tr : LK.requested.tr}: ${widget.status.newValue}'
        : isRejected
        ? LK.rejected.tr
        : LK.requested.tr;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 2.0 * (1.0 - _pulseAnimation.value),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                statusText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: baseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 8,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
