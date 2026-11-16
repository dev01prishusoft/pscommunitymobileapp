import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfigModel {
  final String baseUrl;
  final String devUrl;
  final String stagingUrl;
  final String uiBaseUrl;
  final String devUiBaseUrl;
  final String flavor;

  const AppConfigModel({
    required this.baseUrl,
    required this.devUrl,
    required this.stagingUrl,
    required this.uiBaseUrl,
    required this.devUiBaseUrl,
    required this.flavor,
  });

  /// Reads fallback configuration directly from .env file
  factory AppConfigModel.fallback() {
    return AppConfigModel(
      baseUrl: dotenv.maybeGet('BASE_URL') ?? '',
      devUrl: dotenv.maybeGet('DEV_URL') ?? '',
      stagingUrl: dotenv.maybeGet('STAGING_URL') ?? '',
      uiBaseUrl: dotenv.maybeGet('UI_BASE_URL') ?? '',
      devUiBaseUrl: dotenv.maybeGet('DEV_UI_BASE_URL') ?? '',
      flavor: dotenv.maybeGet('FLAVOR') ?? 'prod',
    );
  }

  factory AppConfigModel.fromMap(Map<String, dynamic> map) {
    final fallback = AppConfigModel.fallback();
    return AppConfigModel(
      baseUrl: _getValue(map, ['BASE_URL', 'baseUrl', 'base_url']) ?? fallback.baseUrl,
      devUrl: _getValue(map, ['DEV_URL', 'devUrl', 'dev_url']) ?? fallback.devUrl,
      stagingUrl: _getValue(map, ['STAGING_URL', 'stagingUrl', 'staging_url']) ?? fallback.stagingUrl,
      uiBaseUrl: _getValue(map, ['UI_BASE_URL', 'uiBaseUrl', 'ui_base_url']) ?? fallback.uiBaseUrl,
      devUiBaseUrl: _getValue(map, ['DEV_UI_BASE_URL', 'devUiBaseUrl', 'dev_ui_base_url']) ?? fallback.devUiBaseUrl,
      flavor: _getValue(map, ['FLAVOR', 'flavor']) ?? fallback.flavor,
    );
  }

  static String? _getValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null && map[key].toString().trim().isNotEmpty) {
        return map[key].toString().trim();
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'BASE_URL': baseUrl,
      'DEV_URL': devUrl,
      'STAGING_URL': stagingUrl,
      'UI_BASE_URL': uiBaseUrl,
      'DEV_UI_BASE_URL': devUiBaseUrl,
      'FLAVOR': flavor,
    };
  }
}

class FirebaseDatabaseService {
  FirebaseDatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String appConfigCollection = 'AppConfig';

  /// Fetches the application configuration from the "AppConfig" collection in Firestore.
  /// If [docId] is provided, it attempts to fetch that specific document first.
  /// Otherwise, it retrieves the first available document in the collection.
  Future<AppConfigModel?> fetchAppConfig({String? docId}) async {
    try {
      if (docId != null && docId.isNotEmpty) {
        final doc =
            await _firestore.collection(appConfigCollection).doc(docId).get();
        if (doc.exists && doc.data() != null) {
          return AppConfigModel.fromMap(doc.data()!);
        }
      }

      final querySnapshot =
          await _firestore.collection(appConfigCollection).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return AppConfigModel.fromMap(querySnapshot.docs.first.data());
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Returns a reference to any Firestore collection for general database access.
  CollectionReference<Map<String, dynamic>> collection(String collectionName) {
    return _firestore.collection(collectionName);
  }
}
