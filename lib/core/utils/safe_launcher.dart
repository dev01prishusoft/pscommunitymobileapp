import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeLauncher {
  SafeLauncher._();
  static const Set<String> _allowedSchemes = {'https', 'tel', 'mailto'};

  static void _showUnavailableToast() {
    PSDelightToastBar(
      builder: (context) => ToastCard(
        title: LK.error.tr,
        subtitle: LK.tryAgain.tr,
        isErrorMessage: true,
      ),
    ).show();
  }

  static Future<bool> open(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !_allowedSchemes.contains(uri.scheme)) {
      _showUnavailableToast();
      return false;
    }

    try {
      final mode = uri.scheme == 'https'
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;

      final launched = await launchUrl(uri, mode: mode);
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
}
