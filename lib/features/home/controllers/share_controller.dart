import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/models/app_link_model.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareController extends GetxController {
  ShareController(this._apiClient);
  final ApiClient _apiClient;

  final RxInt selectedIndex = 0.obs;

  final RxBool isLoading = false.obs;
  final RxnString applinkError = RxnString();

  final RxList<AppLinkModel> appLinks = <AppLinkModel>[].obs;

  String get appLink => AppEnvironment.I.uiBaseUrl;

  String get _allLinksText {
    return appLinks.map((e) => '${e.appType}\n${e.appLink}').join('\n');
  }

  String get _shareBody {
    final samajName =
        Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr;

    return '''
      ${LK.shareMessageTemplate.tr.replaceFirst('@samaj', samajName)}

      $_allLinksText
      ''';
  }

  Future<void> fetchAppLinks() async {
    if (isLoading.value) return;

    isLoading.value = true;
    applinkError.value = null;

    try {
      final response = await _apiClient.get(ApiEndpoints.appLinks);

      final data = response.data['data'] as List<dynamic>;

      appLinks.assignAll(
        data.map((e) => AppLinkModel.fromJson(e as Map<String, dynamic>)),
      );

      update();
    } catch (e) {
      applinkError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void copyLink() {
    Clipboard.setData(ClipboardData(text: _allLinksText));

    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) =>
          ToastCard(title: LK.linkCopied.tr),
    ).show();
  }

  Rect _fallbackOrigin() {
    if (Get.context != null) {
      final size = MediaQuery.sizeOf(Get.context!);
      return Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 1,
        height: 1,
      );
    }
    return const Rect.fromLTWH(0, 0, 100, 100);
  }

  Future<void> shareViaWhatsApp({Rect? sharePositionOrigin}) async {
    final encoded = Uri.encodeComponent(_shareBody);

    final uri = Uri.parse('https://wa.me/?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await shareGeneral(sharePositionOrigin: sharePositionOrigin);
    }
  }

  Future<void> shareGeneral({Rect? sharePositionOrigin}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: _shareBody,
        sharePositionOrigin: sharePositionOrigin ?? _fallbackOrigin(),
      ),
    );
  }

  void shareSelectedLink(AppLinkModel link, {Rect? sharePositionOrigin}) {
    final samajName =
        Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr;

    final text =
        '''
    ${LK.shareMessageTemplate.tr.replaceFirst('@samaj', samajName)}

    ${link.appType}
    ${link.appLink}
    ''';

    SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: sharePositionOrigin ?? _fallbackOrigin(),
      ),
    );
  }

  AppLinkModel? get selectedLink {
    if (appLinks.isEmpty) return null;
    return appLinks[selectedIndex.value];
  }
}
