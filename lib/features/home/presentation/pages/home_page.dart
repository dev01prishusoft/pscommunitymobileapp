import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceVariant,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyBlue),
        actions: [
          _buildLanguageDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
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
    final samajController = Get.find<SamajController>();
    
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    samajController.samaj.value?.name ?? LK.samajName.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyBlue,
                    letterSpacing: 0.2,
                  ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Obx(() {
            final logoUrl = samajController.samaj.value?.logoUrl;
            return Container(
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
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/prishusoft_logo.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          'assets/images/prishusoft_logo.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            );
          }),
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
            onTap: () => Get.toNamed<void>(AppRouter.payments),
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
    final loc = Get.find<LocalizationService>();
    if (loc.languages.isEmpty) {
      loc.fetchLanguages();
    }

    return Obx(() {
      final currentLang = (Get.locale?.languageCode ?? 'en').toUpperCase();
      
      final List<String> codes = loc.languages.isEmpty 
          ? ['EN', 'GU'] 
          : loc.languages.map((l) => l.code.toUpperCase()).toSet().toList();

      if (!codes.contains(currentLang) && codes.isNotEmpty) {
        // If current locale is not in the list, we don't change it but we must ensure the dropdown has a valid value
        // or add the current one to the list temporarily.
        codes.add(currentLang);
      }

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
            value: codes.contains(currentLang) ? currentLang : codes.first,
            icon: const Icon(
              Icons.language,
              color: AppColors.navyBlue,
              size: 18,
            ),
            style: const TextStyle(
              color: AppColors.navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: codes.map((code) => DropdownMenuItem(
              value: code,
              child: Text(' $code'),
            )).toList(),
            onChanged: (String? newValue) {
              if (newValue == 'EN') {
                loc.changeLocale('en', 'US');
              } else if (newValue == 'GU') {
                loc.changeLocale('gu', 'IN');
              } else if (newValue != null) {
                loc.changeLocale(newValue.toLowerCase(), '');
              }
            },
          ),
        ),
      );
    });
  }
}

