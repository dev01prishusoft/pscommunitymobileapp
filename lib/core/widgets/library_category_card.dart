import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/models/library_category_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';

class LibraryCategoryCard extends StatelessWidget {
  final LibraryCategoryModel category;
  final VoidCallback onTap;

  const LibraryCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _resolveIcon(category.iconType);
    final cleanDesc = category.description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
    final hasDesc = cleanDesc.isNotEmpty &&
        cleanDesc.toLowerCase() != category.name.trim().toLowerCase();

    final iconColor = category.iconColorResolved;
    final containerBg = category.backgroundColor;

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
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: hasDesc ? 14.h : 12.h,
            ),
            child: Row(
              children: [
                // Category Icon Container (dynamically styled from iconColor)
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: containerBg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name,
                        maxLines: hasDesc ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                      if (hasDesc) ...[
                        SizedBox(height: 3.h),
                        Text(
                          cleanDesc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      SizedBox(height: hasDesc ? 3.h : 4.h),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),
                // Trailing Arrow
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

  static IconData _resolveIcon(String iconType) {
    switch (iconType.toLowerCase().trim()) {
      case 'flower':
      case 'lotus':
      case 'spa':
        return Icons.spa_rounded;
      case 'document':
      case 'report':
      case 'file':
        return Icons.description_rounded;
      case 'article':
      case 'rules':
      case 'newspaper':
      case 'news':
        return Icons.article_rounded;
      case 'video':
      case 'guide':
      case 'movie':
        return Icons.play_circle_fill_rounded;
      case 'audio':
      case 'music':
      case 'sound':
      case 'song':
        return Icons.audiotrack_rounded;
      case 'book':
      case 'library':
      case 'read':
        return Icons.menu_book_rounded;
      case 'image':
      case 'photo':
      case 'picture':
      case 'gallery':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'shield':
      case 'security':
        return Icons.shield_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}
