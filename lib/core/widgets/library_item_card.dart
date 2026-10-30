import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const LibraryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _getItemMeta(item.type);
    final displayDate = formatDateString(item.date, fallback: '');
    final cleanDescription = item.description.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    final hasSubtitle = cleanDescription.isNotEmpty &&
        cleanDescription.toLowerCase() != item.title.trim().toLowerCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: hasSubtitle ? 12.h : 11.h,
            ),
            child: Row(
              children: [
                // Leading Icon Container
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: meta.bgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      meta.icon,
                      color: meta.iconColor,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: hasSubtitle ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                      if (hasSubtitle) ...[
                        SizedBox(height: 3.h),
                        Text(
                          cleanDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      SizedBox(height: hasSubtitle ? 5.h : 4.h),
                      Row(
                        children: [
                          if (displayDate.isNotEmpty) ...[
                            Text(
                              displayDate,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: meta.badgeBgColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.type.isNotEmpty ? item.type : LK.library_item_type_fallback.tr,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: meta.badgeTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing Chevron
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _ItemMeta _getItemMeta(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return _ItemMeta(
          icon: Icons.picture_as_pdf_rounded,
          iconColor: const Color(0xFFE53935),
          bgColor: const Color(0xFFFFEBEE),
          badgeBgColor: const Color(0xFFFFEBEE),
          badgeTextColor: const Color(0xFFD32F2F),
        );
      case 'MP3':
        return _ItemMeta(
          icon: Icons.music_note_rounded,
          iconColor: const Color(0xFF8E24AA),
          bgColor: const Color(0xFFF3E5F5),
          badgeBgColor: const Color(0xFFF3E5F5),
          badgeTextColor: const Color(0xFF7B1FA2),
        );
      case 'TEXT':
        return _ItemMeta(
          icon: Icons.article_rounded,
          iconColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          badgeBgColor: const Color(0xFFE8F5E9),
          badgeTextColor: const Color(0xFF2E7D32),
        );
      case 'VIDEO':
        return _ItemMeta(
          icon: Icons.play_circle_fill_rounded,
          iconColor: const Color(0xFF1976D2),
          bgColor: const Color(0xFFE3F2FD),
          badgeBgColor: const Color(0xFFE3F2FD),
          badgeTextColor: const Color(0xFF1976D2),
        );
      case 'IMAGE':
        return _ItemMeta(
          icon: Icons.photo_library_rounded,
          iconColor: const Color(0xFFE65100),
          bgColor: const Color(0xFFFFF3E0),
          badgeBgColor: const Color(0xFFFFF3E0),
          badgeTextColor: const Color(0xFFE65100),
        );
      default:
        return _ItemMeta(
          icon: Icons.insert_drive_file_rounded,
          iconColor: const Color(0xFF546E7A),
          bgColor: const Color(0xFFECEFF1),
          badgeBgColor: const Color(0xFFECEFF1),
          badgeTextColor: const Color(0xFF546E7A),
        );
    }
  }
}

class _ItemMeta {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color badgeBgColor;
  final Color badgeTextColor;

  _ItemMeta({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });
}

