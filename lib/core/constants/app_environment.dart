import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pscommunitymobileapp/core/services/firebase_database_service.dart';

enum Flavor { dev, prod }

class AppEnvironment {
  AppEnvironment._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.uiBaseUrl,
    required this.devUrl,
    required this.stagingUrl,
    required this.devUiBaseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
    this.enableLogging = true,
  });

  static AppEnvironment? _instance;

  static AppEnvironment get I {
    if (_instance == null) {
      throw StateError('AppEnvironment not initialized. Call init() first.');
    }
    return _instance!;
  }

  final Flavor flavor;
  final String apiBaseUrl;
  final String uiBaseUrl;
  final String devUrl;
  final String stagingUrl;
  final String devUiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  bool get isProd => flavor == Flavor.prod;
  bool get isDev => flavor == Flavor.dev;

  String get privacyPolicyUrl => '$uiBaseUrl/privacy-policy';
  String get termsAndConditionsUrl => '$uiBaseUrl/terms-and-conditions';

  static Future<void> init({
    FirebaseDatabaseService? firebaseService,
    String? docId,
  }) async {
    if (_instance != null) return;

    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {}
    }

    final service = firebaseService ?? FirebaseDatabaseService();
    AppConfigModel? config;

    try {
      config = await service
          .fetchAppConfig(docId: docId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return null;
            },
          );
    } catch (_) {}

    config ??= AppConfigModel.fallback();

    const envFlavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    final resolvedFlavorString = envFlavor.isNotEmpty
        ? envFlavor
        : config.flavor;
    final flavor = resolvedFlavorString.toLowerCase() == 'dev'
        ? Flavor.dev
        : Flavor.prod;

    _instance = AppEnvironment._(
      flavor: flavor,
      apiBaseUrl: flavor == Flavor.prod ? config.baseUrl : config.devUrl,
      uiBaseUrl: flavor == Flavor.prod ? config.uiBaseUrl : config.devUiBaseUrl,
      devUrl: config.devUrl,
      stagingUrl: config.stagingUrl,
      devUiBaseUrl: config.devUiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      enableLogging: flavor == Flavor.dev,
    );
  }
}
