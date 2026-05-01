import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Business Information'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildCategoryCard(
                context,
                icon: Icons.directions_car_rounded,
                title: 'Automobile'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.more_horiz_rounded,
                title: 'Other'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.chair_rounded,
                title: 'Furniture'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.school_rounded,
                title: 'Education / Training'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.local_hospital_rounded,
                title: 'Health / Medical'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.electrical_services_rounded,
                title: 'Electronics / Electrician'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.dry_cleaning_rounded,
                title: 'Tailor / Garments'.tr,
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                icon: Icons.face_retouching_natural_rounded,
                title: 'Beauty / Cosmetics'.tr,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Icon Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.3,
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
