import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_webview_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeLauncher {
  SafeLauncher._();
  static const Set<String> _allowedSchemes = {'https', 'http', 'tel', 'mailto'};

  static void _showUnavailableToast() {
    PSDelightToastBar(
      builder: (context) => ToastCard(
        title: LK.error.tr,
        subtitle: LK.tryAgain.tr,
        isErrorMessage: true,
      ),
    ).show();
  }

  static Future<bool> open(String rawUrl, {LaunchMode? mode}) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !_allowedSchemes.contains(uri.scheme)) {
      _showUnavailableToast();
      return false;
    }

    try {
      final launchMode = mode ??
          (uri.scheme == 'https' || uri.scheme == 'http'
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault);

      final launched = await launchUrl(uri, mode: launchMode);
      if (!launched) {
        _showUnavailableToast();
      }
      return launched;
    } catch (e, stack) {
      final scheme = uri.scheme;
      CrashReporter.recordError(
        e,
        stack,
        reason: 'SafeLauncher.open failed (scheme: $scheme)',
      );
      _showUnavailableToast();
      return false;
    }
  }

  static Future<bool> openExternal(String rawUrl) async {
    return open(rawUrl, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openInAppBrowser(String rawUrl, {String? title}) async {
    final trimmed = rawUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showUnavailableToast();
      return false;
    }

    try {
      Get.to(
        () => AppWebViewPage(
          title: title != null && title.trim().isNotEmpty
              ? title.trim()
              : (uri.host.isNotEmpty ? uri.host : 'Browser'),
          url: trimmed,
          allowAnyUrl: true,
        ),
      );
      return true;
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'SafeLauncher.openInAppBrowser failed, falling back to external',
      );
      return openExternal(trimmed);
    }
  }
}
