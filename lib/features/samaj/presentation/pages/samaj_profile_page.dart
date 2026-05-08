import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class SamajProfilePage extends StatelessWidget {
  const SamajProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LK.samajInfo.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance,
                      size: 60, color: AppColors.navyBlue),
                  const SizedBox(height: 16),
                  Text(
                    LK.samajName.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LK.samajSubtitle.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // Timeline/Hierarchical view
            _buildTimelineItem(
              context,
              title: LK.samajSanstha.tr,
              icon: Icons.account_balance,
              iconColor: AppColors.deepBlue,
              onTap: () => Navigator.pushNamed(context, AppRouter.samajSanstha),
              isLast: false,
            ),
            _buildTimelineItem(
              context,
              title: LK.bankAccounts.tr,
              icon: Icons.account_balance,
              iconColor: AppColors.deepGreen,
              onTap: () => Navigator.pushNamed(context, AppRouter.bankDetails),
              isLast: true,
              isGreen: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLast = false,
    bool isGreen = false,
  }) {
    return Column(
      children: [
        // Vertical connector line from top
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.shade300,
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isGreen ? AppColors.lightGreen : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGreen ? const Color(0xFFC8E6C9) : AppColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGreen ? AppColors.deepGreen : AppColors.deepBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                if (!isGreen)
                  Text(
                    LK.view.tr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isGreen ? AppColors.deepGreen : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
