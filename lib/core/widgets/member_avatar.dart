import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
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
    final memCacheSize = (radius * 3).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
        child: _buildContent(fallbackNameStr, memCacheSize),
      ),
    );
  }

  Widget _buildContent(String name, int memCacheSize) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedImg(
        url: imageUrl!,
        memCacheHeight: memCacheSize,
        memCacheWidth: memCacheSize,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => _buildInitialsOrIcon(name),
      );
    }
    return _buildInitialsOrIcon(name);
  }

  Widget _buildInitialsOrIcon(String name) {
    if (name.isNotEmpty) {
      final initials = _getInitials(name);
      return Text(
        initials,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Icon(Icons.person, color: AppColors.primary);
  }

  String _getInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
