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
    final fallbackNameStr = fallbackName?.trim() ?? '';
    final avatarColors = _getAvatarColors(gender ?? '', fallbackNameStr);
    final memCacheSize = (radius * 3).toInt();

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedImg(
        url: imageUrl!,
        memCacheHeight: memCacheSize,
        memCacheWidth: memCacheSize,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: radius, backgroundImage: imageProvider),
        placeholder: (context, url) =>
            _buildFallback(avatarColors, fallbackNameStr, isLoading: true),
        errorWidget: (context, url, error) => _buildFallback(avatarColors, fallbackNameStr),
      );
    }

    return _buildFallback(avatarColors, fallbackNameStr);
  }

  Widget _buildFallback(
    ({Color background, Color icon}) colors, 
    String name, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: colors.background,
        child: CircularProgressIndicator(strokeWidth: 2, color: colors.icon),
      );
    }

    if (name.isNotEmpty) {
      final initials = _getInitials(name);
      return CircleAvatar(
        radius: radius,
        backgroundColor: colors.background,
        child: Text(
          initials,
          style: AppTextStyles.labelLarge.copyWith(
            color: colors.icon,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
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

  String _getInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ({Color background, Color icon}) _getAvatarColors(String gender, String name) {
    if (gender.toLowerCase() == 'female') {
      return (background: Color(0xFFFCE4EC), icon: Colors.pink);
    }
    return (background: AppColors.primary.withValues(alpha: 0.1), icon: AppColors.primary);
  }
}
