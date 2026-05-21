import 'package:pscommunitymobileapp/core/constants/api_constants.dart';

enum Flavor { dev, prod }

class AppEnvironment {
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
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  bool get isProd => flavor == Flavor.prod;
  bool get isDev => flavor == Flavor.dev;

  String get privacyPolicyUrl => '$uiBaseUrl/privacy-policy';
  String get termsAndConditionsUrl => '$uiBaseUrl/terms-and-conditions';

  AppEnvironment._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.uiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.enableLogging = true,
  });

  static void init() {
    if (_instance != null) return;
    const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    final flavor = flavorString == 'prod' ? Flavor.prod : Flavor.dev;

    _instance = AppEnvironment._(
      flavor: flavor,
      apiBaseUrl: flavor == Flavor.prod 
          ? ApiConstants.baseUrl 
          : ApiConstants.devUrl,
      uiBaseUrl: flavor == Flavor.prod
          ? ApiConstants.uiBaseUrl
          : ApiConstants.devUiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      enableLogging: flavor == Flavor.dev,
    );
  }
}
