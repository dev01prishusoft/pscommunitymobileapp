import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final samajController = Get.find<SamajController>();
    final authState = Get.find<AuthState>();

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Obx(() {
            final samaj = samajController.samaj.value;
            final logoUrl = samaj?.logoUrl;
            
            return UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.navyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
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
              accountName: Text(
                samaj?.name ?? LK.samajName.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                samaj?.descriptionEnglish ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.primary),
            title: Text(LK.home.tr),
            onTap: () => Get.back<void>(),
          ),
          ListTile(
            leading: const Icon(Icons.person_search_outlined, color: AppColors.primary),
            title: Text(LK.findMember.tr),
            onTap: () => Get.toNamed<void>(AppRouter.findMember),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline, color: AppColors.primary),
            title: Text('Marriage'.tr),
            onTap: () => Get.toNamed<void>(AppRouter.marriage),
          ),
          
          const Spacer(),
          const Divider(),
          
          // Logout Item
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              'Logout'.tr,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Get.back(); // Close drawer
              _showLogoutDialog(context, authState);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthState authState) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Logout'.tr),
        content: Text('Are you sure you want to logout?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: AppPrimaryButton(
              text: 'Logout'.tr,
              height: 45,
              onPressed: () {
                authState.logout();
                Get.offAllNamed<void>(AppRouter.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}
