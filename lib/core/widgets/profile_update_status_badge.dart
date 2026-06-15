import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';

class ProfileUpdateStatusBadge extends StatelessWidget {
  const ProfileUpdateStatusBadge({super.key, required this.status});
  final ProfileUpdateStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.isApproved) return const SizedBox.shrink();

    final isRejected = status.isRejected;
    final color = isRejected ? AppColors.red : Colors.orange;
    final bgColor = isRejected ? AppColors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRejected ? Icons.cancel_outlined : Icons.pending_actions,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${isRejected ? 'Rejected'.tr : 'Requested'.tr}: ${status.newValue}',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
