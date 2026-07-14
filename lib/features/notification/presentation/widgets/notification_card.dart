import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final MemberNotification notification;
  final VoidCallback onTap;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (_) {
      return '';
    }
  }

  Widget _buildIconContainer() {
    IconData iconData = Icons.notifications_none_rounded;
    Color iconColor = AppColors.primary;
    Color bgColor = AppColors.primary.withValues(alpha: 0.08);

    final type = widget.notification.announcementType?.toLowerCase() ?? '';
    final msg = widget.notification.message.toLowerCase();

    if (type.contains('event') ||
        msg.contains('event') ||
        msg.contains('પ્રોગ્રામ') ||
        msg.contains('કાર્યક્રમ')) {
      iconData = Icons.event_note_rounded;
      iconColor = AppColors.chart1;
      bgColor = iconColor.withValues(alpha: 0.08);
    } else if (type.contains('urgent') ||
        type.contains('alert') ||
        msg.contains('urgent') ||
        msg.contains('તાકીદ')) {
      iconData = Icons.warning_amber_rounded;
      iconColor = AppColors.orange;
      bgColor = iconColor.withValues(alpha: 0.08);
    } else if (type.contains('meeting') ||
        msg.contains('meeting') ||
        msg.contains('સભા') ||
        msg.contains('બેઠક')) {
      iconData = Icons.groups_rounded;
      iconColor = AppColors.chart5;
      bgColor = iconColor.withValues(alpha: 0.08);
    } else if (type.contains('wedding') ||
        msg.contains('wedding') ||
        msg.contains('લગ્ન')) {
      iconData = Icons.favorite_rounded;
      iconColor = AppColors.red;
      bgColor = iconColor.withValues(alpha: 0.08);
    } else if (type.contains('news') ||
        msg.contains('news') ||
        msg.contains('સમાચાર')) {
      iconData = Icons.newspaper_rounded;
      iconColor = const Color(0xFF1B5E20);
      bgColor = iconColor.withValues(alpha: 0.08);
    }

    return Container(
      width: 35.w,
      height: 35.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(iconData, color: iconColor, size: 20.sp),
    );
  }

  Widget _buildCategoryBadge(String text) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white, width: 0.5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            LK.newLabel.tr,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLongText = widget.notification.message.length > 80;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s.h),
      decoration: BoxDecoration(
        color: widget.notification.isRead
            ? AppColors.white
            : AppColors.primary.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.notification.isRead
              ? AppColors.grey.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: widget.onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.l.w,
                      vertical: AppSpacing.l.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconContainer(),
                        SizedBox(width: AppSpacing.m.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.notification.announcementType !=
                                          null &&
                                      widget
                                          .notification
                                          .announcementType!
                                          .isNotEmpty)
                                    _buildCategoryBadge(
                                      widget.notification.announcementType!.tr,
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  if (!widget.notification.isRead)
                                    _buildNewBadge(),
                                ],
                              ),

                              if (widget.notification.announcementType !=
                                      null &&
                                  widget
                                      .notification
                                      .announcementType!
                                      .isNotEmpty) ...[
                                Text(
                                  widget.notification.message,
                                  maxLines: _isExpanded
                                      ? null
                                      : (isLongText ? 3 : null),
                                  overflow: _isExpanded
                                      ? null
                                      : (isLongText
                                            ? TextOverflow.ellipsis
                                            : null),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: widget.notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (isLongText) ...[
                                InkWell(
                                  onTap: () => setState(
                                    () => _isExpanded = !_isExpanded,
                                  ),
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isExpanded
                                            ? LK.showLess.tr
                                            : LK.showMore.tr,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Icon(
                                        _isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 16.sp,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              10.verticalSpace,
                              Text(
                                _formatDate(widget.notification.sendTime),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.grey.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
