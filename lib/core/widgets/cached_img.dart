import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CachedImg extends StatelessWidget {
  const CachedImg({
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.memCacheHeight,
    this.memCacheWidth,
    this.width,
    this.height,
    super.key,
  });
  final String url;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final int? memCacheHeight;
  final int? memCacheWidth;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return errorWidget?.call(context, url, null) ??
          Icon(Icons.broken_image, color: AppColors.grey);
    }

    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      cacheHeight: memCacheHeight,
      cacheWidth: memCacheWidth,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder?.call(context, url) ??
            Center(
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget?.call(context, url, error) ??
            Icon(Icons.error, color: AppColors.red);
      },
    );
  }
}
