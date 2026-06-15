import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImg extends StatelessWidget {
  const CachedImg({
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.imageBuilder,
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
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
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

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      imageBuilder: imageBuilder,
      placeholder:
          placeholder ??
          (_, __) => Center(
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget:
          errorWidget ??
          (_, __, ___) => Icon(Icons.error, color: AppColors.redAccent),
      fadeInDuration: Duration(milliseconds: 300),
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
    );
  }
}
