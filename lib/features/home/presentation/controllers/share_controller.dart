import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class ShareController extends GetxController {
  String get appLink => AppEnvironment.I.uiBaseUrl;
  String get _shareBody {
    final samajName =
        Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr;
    return LK.shareMessageTemplate.tr
        .replaceFirst('@samaj', samajName)
        .replaceFirst('@link', appLink);
  }

  void copyLink() {
    Clipboard.setData(ClipboardData(text: appLink));
    Get.snackbar(
      LK.linkCopied.tr,
      appLink,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  Future<void> shareViaWhatsApp() async {
    final encoded = Uri.encodeComponent(_shareBody);
    final uri = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await shareGeneral();
    }
  }

  Future<void> shareGeneral() async {
    await SharePlus.instance.share(ShareParams(text: _shareBody));
  }
}
