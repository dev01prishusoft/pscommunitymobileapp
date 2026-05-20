import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

/// Owns all share-related logic so the page is a pure UI shell.
class ShareController extends GetxController {
  // ─── App Link ─────────────────────────────────────────────────────────────

  /// The deep-link / public download URL for this community app.
  String get appLink => AppEnvironment.I.uiBaseUrl;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Localised message body that includes the samaj name and app link.
  String get _shareBody {
    final samajName =
        Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr;
    return LK.shareMessageTemplate.tr
        .replaceFirst('@samaj', samajName)
        .replaceFirst('@link', appLink);
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Copies the app link to the clipboard and shows a confirmation snackbar.
  void copyLink() {
    Clipboard.setData(ClipboardData(text: appLink));
    Get.snackbar(
      LK.linkCopied.tr,
      appLink,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Opens WhatsApp with a pre-filled share message.
  /// Falls back to [shareGeneral] if WhatsApp is not installed.
  Future<void> shareViaWhatsApp() async {
    final encoded = Uri.encodeComponent(_shareBody);
    final uri = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await shareGeneral();
    }
  }

  /// Opens the OS share sheet with the localised share message.
  Future<void> shareGeneral() async {
    await SharePlus.instance.share(ShareParams(text: _shareBody));
  }
}
