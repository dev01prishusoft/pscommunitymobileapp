import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeLauncher {
  SafeLauncher._();
  static const Set<String> _allowedSchemes = {'https', 'tel', 'mailto'};
  
  static Future<bool> open(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !_allowedSchemes.contains(uri.scheme)) {
      return false;
    }

    try {
      final mode = uri.scheme == 'https'
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;

      if (!await canLaunchUrl(uri)) return false;
      await launchUrl(uri, mode: mode);
      return true;
    } catch (e, stack) {
      final scheme = uri.scheme;
      CrashReporter.recordError(
        e,
        stack,
        reason: 'SafeLauncher.open failed (scheme: $scheme)',
      );
      return false;
    }
  }
}
