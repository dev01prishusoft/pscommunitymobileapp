import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/network/auth_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/retry_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/error_mapping_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/certificate_pinning.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ApiClient {
  late final Dio _dio;
  final ConnectivityService _connectivity;

  ApiClient({
    required TokenManager tokenManager,
    required ConnectivityService connectivity,
    required VoidCallback onAuthFailure,
  }) : _connectivity = connectivity {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnvironment.I.apiBaseUrl,
      connectTimeout: AppEnvironment.I.connectTimeout,
      receiveTimeout: AppEnvironment.I.receiveTimeout,
    ));

    final refreshDio = Dio(BaseOptions(baseUrl: AppEnvironment.I.apiBaseUrl));

    CertificatePinning.configure(_dio);

    _dio.interceptors.addAll([
      AuthInterceptor(
        tokenManager: tokenManager,
        refreshDio: refreshDio,
        onAuthFailure: onAuthFailure,
      ),
      RetryInterceptor(),
      ErrorMappingInterceptor(),
      if (AppEnvironment.I.enableLogging)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          compact: true,
        ),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    await _checkConnectivity();
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    await _checkConnectivity();
    return _dio.post(path, data: data);
  }

  Future<void> _checkConnectivity() async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkFailure();
    }
  }

  void close() {
    _dio.close();
  }
}
