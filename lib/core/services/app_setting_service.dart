import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pscommunitymobileapp/core/models/app_setting_model.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';

/// Fetches server-driven app settings (e.g. the Google Places API key) and
/// caches them in memory for the app session.
///
/// Never throws: on any failure the key resolves to an empty string so callers
/// can fall back gracefully, and the next call retries the request.
class AppSettingService extends GetxService {
  AppSettingService(this._apiClient);

  static AppSettingService? get maybe => Get.isRegistered<AppSettingService>()
      ? Get.find<AppSettingService>()
      : null;

  final ApiClient _apiClient;

  AppSettingModel? _settings;
  Future<AppSettingModel?>? _inFlight;

  /// Returns the cached key synchronously, or an empty string if not loaded.
  String get cachedGoogleApiKey => _settings?.googleApiKey ?? '';

  Future<String> getGoogleApiKey() async {
    final settings = await _load();
    return settings?.googleApiKey ?? '';
  }

  Future<AppSettingModel?> _load() {
    final cached = _settings;
    if (cached != null && cached.googleApiKey.isNotEmpty) {
      return Future.value(cached);
    }
    // Share a single request between concurrent callers.
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<AppSettingModel?> _fetch() async {
    try {
      final response = await _apiClient.request(
        ApiEndpoints.appSetting,
        options: Options(extra: {'skipErrorScreen': true}),
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;

      final parsed = ApiResponse<AppSettingModel>.fromJson(
        body,
        (json) => AppSettingModel.fromJson(json as Map<String, dynamic>),
      );
      final settings = parsed.data;
      if (settings != null) _settings = settings;
      return settings;
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'AppSettingService._fetch failed',
      );
      return null;
    }
  }
}
