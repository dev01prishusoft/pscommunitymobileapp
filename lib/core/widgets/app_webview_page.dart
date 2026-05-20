import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';

class AppWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const AppWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  late final WebViewController _controller;
  int _loadingPercentage = 0;

  bool _isUrlAllowed(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      
      // Only allow http or https scheme inside the webview
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      final host = uri.host.toLowerCase();
      
      final allowedUiUri = Uri.parse(AppEnvironment.I.uiBaseUrl);
      final allowedApiUri = Uri.parse(AppEnvironment.I.apiBaseUrl);

      final allowedUiHost = allowedUiUri.host.toLowerCase();
      final allowedApiHost = allowedApiUri.host.toLowerCase();

      bool matchesAllowedHost(String allowedHost) {
        if (allowedHost.isEmpty) return false;
        return host == allowedHost || host.endsWith('.$allowedHost');
      }

      return matchesAllowedHost(allowedUiHost) || matchesAllowedHost(allowedApiHost);
    } catch (_) {
      return false;
    }
  }

  Future<void> _launchExternal(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (urlString.startsWith('tel:')) {
        final String number = urlString.replaceFirst('tel:', '');
        final Uri telUri = Uri(scheme: 'tel', path: number);
        await launchUrl(telUri);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch URL: $urlString');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            if (_isUrlAllowed(url)) {
              return NavigationDecision.navigate;
            }
            await _launchExternal(url);
            return NavigationDecision.prevent;
          },
        ),
      );

    if (_isUrlAllowed(widget.url)) {
      _controller.loadRequest(Uri.parse(widget.url));
    } else {
      _launchExternal(widget.url);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(
              value: _loadingPercentage / 100.0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
        ],
      ),
    );
  }
}
