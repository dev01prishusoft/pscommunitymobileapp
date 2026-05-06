import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildLanguageDropdown(),
                  ),
                ),
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildGrid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LK.samajName.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyBlue,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/prishusoft_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildMenuItem(
            context,
            icon: Icons.family_restroom,
            title: LK.family.tr,
            onTap: () => Get.toNamed<void>(AppRouter.familyAreas),
          ),
          _buildMenuItem(
            context,
            icon: Icons.person_search,
            title: LK.findMember.tr,
            onTap: () => Get.toNamed<void>(AppRouter.findMember),
          ),
          _buildMenuItem(
            context,
            icon: Icons.groups_outlined,
            title: LK.committee.tr,
            onTap: () => Get.toNamed<void>(AppRouter.committees),
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance_wallet,
            title: LK.payment.tr,
            onTap: () => Get.toNamed<void>(AppRouter.paymentHistory),
          ),
          _buildMenuItem(
            context,
            icon: Icons.work,
            title: LK.occupationDirectory.tr,
            onTap: () => Get.toNamed<void>(AppRouter.occupationDirectory),
          ),
          _buildMenuItem(
            context,
            icon: Icons.wc,
            title: LK.matrimonial.tr,
            onTap: () => Get.toNamed<void>(AppRouter.marriage),
          ),
          _buildMenuItem(
            context,
            icon: Icons.share,
            title: LK.share.tr,
            onTap: () => Get.toNamed<void>(AppRouter.shareApp),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: LK.samajInfo.tr,
            onTap: () => Get.toNamed<void>(AppRouter.samajProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.navyBlue,
              ), // Dark Navy
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: Get.locale?.languageCode == 'gu' ? 'GU' : 'EN',
          icon: const Icon(Icons.language, color: AppColors.navyBlue, size: 18),
          style: const TextStyle(
            color: AppColors.navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: const [
            DropdownMenuItem(value: 'EN', child: Text(' EN')),
            DropdownMenuItem(value: 'GU', child: Text(' GU')),
          ],
          onChanged: (String? newValue) {
            final loc = Get.find<LocalizationService>();
            if (newValue == 'EN') {
              loc.changeLocale('en', 'US');
            } else if (newValue == 'GU') {
              loc.changeLocale('gu', 'IN');
            }
          },
        ),
      ),
    );
  }
}

