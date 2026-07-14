import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/home/presentation/model/app_link_model.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
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

    Get.snackbar(
      LK.linkCopied.tr,
      LK.linkCopied.tr,
      snackPosition: SnackPosition.BOTTOM,
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

  void shareSelectedLink(AppLinkModel link) {
    final samajName =
        Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr;

    final text =
        '''
    ${LK.shareMessageTemplate.tr.replaceFirst('@samaj', samajName)}

    ${link.appType}
    ${link.appLink}
    ''';

    SharePlus.instance.share(ShareParams(text: text));
  }

  AppLinkModel? get selectedLink {
    if (appLinks.isEmpty) return null;
    return appLinks[selectedIndex.value];
  }
}
