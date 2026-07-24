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
          appBar: AppBar(
            title: Text(
              LK.share.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, AppColors.sfBackground],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  _HeaderCard(),
                  const SizedBox(height: 20),
                  _AppLinkCard(ctrl: controller),
                  const SizedBox(height: 16),
                  _QrCard(ctrl: controller),
                  const SizedBox(height: 24),
                  _ShareButton(
                    icon: Icons.chat_bubble_rounded,
                    label: LK.shareAppViaWhatsApp.tr,
                    color: const Color(0xFF25D366),
                    onTap: controller.shareViaWhatsApp,
                  ),
                  const SizedBox(height: 14),
                  _ShareButton(
                    icon: Icons.share_rounded,
                    label: LK.shareAppViaOther.tr,
                    color: AppColors.primary,
                    onTap: controller.shareGeneral,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _cardDecoration({double radius = 20}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
  border: Border.all(color: Colors.grey.shade100, width: 1),
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
              width: 76.w,
              height: 76.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? CachedImg(
                        url: logoUrl,
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
            );
          }),
          const SizedBox(height: 18),
          Obx(() {
            final samajName = controller.samaj.value?.name ?? LK.samajName.tr;
            return Text(
              samajName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
                letterSpacing: 0.2,
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            LK.joinCommunity.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                LK.appLinkLabel.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ctrl.appLink,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: ctrl.copyLink,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          LK.copyLink.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(ctrl.appLinks.length, (index) {
                  final item = ctrl.appLinks[index];
                  final isSelected = ctrl.selectedIndex.value == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.selectedIndex.value = index;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          item.appType,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: selected.appLink,
                version: QrVersions.auto,
                size: 190,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppColors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              LK.scanToDownload.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            InkWell(
              onTap: () {
                ctrl.shareSelectedLink(selected);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LK.shareQR.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
