import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class AppWebViewPage extends StatefulWidget {
  const AppWebViewPage({super.key, required this.title, required this.url});
  final String title;
  final String url;

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  late final WebViewController _controller;
  int _loadingPercentage = 0;

  bool _isUrlAllowed(String urlString) {
    try {
      final uri = Uri.parse(urlString);
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

      return matchesAllowedHost(allowedUiHost) ||
          matchesAllowedHost(allowedApiHost);
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
      // Ignore error
    }
  }

  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 0 ||
                progress == 100 ||
                (progress % 10 == 0 && progress != _loadingPercentage)) {
              setState(() {
                _loadingPercentage = progress;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _loadingPercentage = 0;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
            });
          },
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.destructive,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load page',
                      style: AppTextStyles.headlineSmall,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _loadingPercentage = 0;
                        });
                        _controller.reload();
                      },
                      child: Text(LK.retry.tr),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_loadingPercentage < 100 && !_hasError)
            LinearProgressIndicator(
              value: _loadingPercentage / 100.0,
              backgroundColor: AppColors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
        ],
      ),
    );
  }
}
