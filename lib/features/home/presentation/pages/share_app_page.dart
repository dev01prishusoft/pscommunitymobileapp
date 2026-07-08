import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareAppPage extends StatelessWidget {
  const ShareAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShareController>(
      initState: (state) {
        Future.microtask(() {
          state.controller?.fetchAppLinks();
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: Text(LK.share.tr)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _HeaderCard(),
                const SizedBox(height: 20),
                _AppLinkCard(ctrl: controller),
                const SizedBox(height: 12),
                _QrCard(ctrl: controller),
                const SizedBox(height: 24),
                _ShareButton(
                  icon: Icons.chat_bubble,
                  label: LK.shareAppViaWhatsApp.tr,
                  color: const Color(0xFF25D366),
                  onTap: controller.shareViaWhatsApp,
                ),
                const SizedBox(height: 16),
                _ShareButton(
                  icon: Icons.share,
                  label: LK.shareAppViaOther.tr,
                  color: AppColors.primary,
                  onTap: controller.shareGeneral,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
);

class _HeaderCard extends GetView<SamajController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Obx(() {
            final logoUrl = controller.samaj.value?.logoUrl;
            return Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(color: AppColors.grey,width: 0.1)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? CachedImg(
                        url: logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/prishusoft_logo.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/prishusoft_logo.png',
                        fit: BoxFit.cover,
                      ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final samajName = controller.samaj.value?.name ?? LK.samajName.tr;
            return Text(
              samajName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            LK.joinCommunity.tr,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppLinkCard extends StatelessWidget {
  const _AppLinkCard({required this.ctrl});

  final ShareController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LK.appLinkLabel.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  ctrl.appLink,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: ctrl.copyLink,
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  LK.copyLink.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.ctrl});

  final ShareController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.appLinks.isEmpty) {
        return const SizedBox.shrink();
      }

      final selected = ctrl.selectedLink!;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            // Tabs
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(ctrl.appLinks.length, (index) {
                  final item = ctrl.appLinks[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.selectedIndex.value = index;
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ctrl.selectedIndex.value == index
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.appType,
                          style: TextStyle(
                            color: ctrl.selectedIndex.value == index
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            QrImageView(
              data: selected.appLink,
              version: QrVersions.auto,
              size: 200,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.navyBlue,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.navyBlue,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              LK.scanToDownload.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                ctrl.shareSelectedLink(selected);
              },
              icon: const Icon(Icons.share, size: 18),
              label: Text(LK.shareQR.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
