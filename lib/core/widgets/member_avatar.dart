import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.imageUrl,
    this.gender,
    this.radius = 30.0,
    this.fallbackName,
  });
  final String? imageUrl;
  final String? gender;
  final double radius;
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final avatarColors = _getAvatarColors(gender ?? '');
    final memCacheSize = (radius * 3).toInt();

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedImg(
        url: imageUrl!,
        memCacheHeight: memCacheSize,
        memCacheWidth: memCacheSize,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: radius, backgroundImage: imageProvider),
        placeholder: (context, url) =>
            _buildFallback(avatarColors, isLoading: true),
        errorWidget: (context, url, error) => _buildFallback(avatarColors),
      );
    }

    return _buildFallback(avatarColors);
  }

  Widget _buildFallback(
    ({Color background, Color icon}) colors, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: colors.background,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (fallbackName != null && fallbackName!.isNotEmpty) {
      final initial = fallbackName![0].toUpperCase();
      return CircleAvatar(
        radius: radius,
        backgroundColor: colors.background,
        child: Text(
          initial,
          style: AppTextStyles.labelLarge.copyWith(
            color: colors.icon,
            fontSize: radius * 0.8,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.background,
      child: Icon(Icons.person, color: colors.icon, size: radius),
    );
  }

  ({Color background, Color icon}) _getAvatarColors(String gender) {
    if (gender.toLowerCase() == 'female') {
      return (background: Color(0xFFFCE4EC), icon: Colors.pink);
    }
    return (background: Color(0xFFE3F2FD), icon: AppColors.blue);
  }
}
