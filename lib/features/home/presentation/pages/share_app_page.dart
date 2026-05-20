import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

/// Share-the-app screen.
/// All share/copy/WhatsApp logic lives in [ShareController].
class ShareAppPage extends StatelessWidget {
  const ShareAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ShareController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LK.share.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _HeaderCard(),
            const SizedBox(height: 20),
            _AppLinkCard(ctrl: ctrl),
            const SizedBox(height: 12),
            _QrCard(ctrl: ctrl),
            const SizedBox(height: 24),
            _ShareButton(
              icon: Icons.chat_bubble,
              label: LK.shareAppViaWhatsApp.tr,
              color: const Color(0xFF25D366),
              onTap: ctrl.shareViaWhatsApp,
            ),
            const SizedBox(height: 16),
            _ShareButton(
              icon: Icons.share,
              label: LK.shareAppViaOther.tr,
              color: AppColors.primary,
              onTap: ctrl.shareGeneral,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Shared decoration ────────────────────────────────────────────────────────

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

// ─── Header Card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phonelink_setup,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Read samaj name reactively
          Obx(() {
            final samajName =
                Get.find<SamajController>().samaj.value?.name ??
                    LK.samajName.tr;
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

// ─── App Link Card ────────────────────────────────────────────────────────────

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
                  // Allow full link to wrap across lines instead of being cut off
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: ctrl.copyLink, // ← actually copies now
                icon: const Icon(Icons.copy, size: 16, color: AppColors.primary),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

// ─── QR Card ──────────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  const _QrCard({required this.ctrl});

  final ShareController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Real QR code generated from the actual app link
          QrImageView(
            data: ctrl.appLink,
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
          const SizedBox(height: 8),
          Text(
            LK.scanToDownload.tr,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: ctrl.shareGeneral, // Share message (not QR image)
            icon: const Icon(Icons.share, size: 18),
            label: Text(LK.shareQR.tr),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Share Button ─────────────────────────────────────────────────────────────

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
