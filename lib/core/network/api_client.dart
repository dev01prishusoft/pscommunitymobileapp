import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/network/auth_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/retry_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/error_mapping_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/language_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/certificate_pinning.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ApiClient {
  final Dio _dio;
  final ConnectivityService _connectivity;

  ApiClient({
    required TokenManager tokenManager,
    required ConnectivityService connectivity,
    required VoidCallback onAuthFailure,
  })  : _connectivity = connectivity,
        _dio = Dio(BaseOptions(
          baseUrl: AppEnvironment.I.apiBaseUrl,
          connectTimeout: AppEnvironment.I.connectTimeout,
          receiveTimeout: AppEnvironment.I.receiveTimeout,
        )) {

    final refreshDio = Dio(BaseOptions(baseUrl: AppEnvironment.I.apiBaseUrl));

    CertificatePinning.configure(_dio);
    CertificatePinning.configure(refreshDio);

    if (AppEnvironment.I.enableLogging) {
      refreshDio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        compact: true,
      ));
    }

    _dio.interceptors.addAll([
      LanguageInterceptor(),
      AuthInterceptor(
        tokenManager: tokenManager,
        refreshDio: refreshDio,
        mainDio: _dio,
        onAuthFailure: onAuthFailure,
      ),
      RetryInterceptor(dio: _dio),
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

  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
    } on DioException catch (e) {
      if (e.error is Failure) throw e.error as Failure;
      throw const ServerFailure();
    }
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) {
    return request(path, method: 'GET', queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) {
    return request(path, method: 'POST', data: data);
  }

  Future<ApiResponse<T>> getParsed<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
  }) async {
    final response = await get(path, queryParameters: queryParameters);
    return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }

  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    required String listKey,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await get(path, queryParameters: queryParameters);
    return PaginatedResponse<T>.fromJson(
      response.data as Map<String, dynamic>,
      listKey,
      fromJsonT,
    );
  }
  
  Future<ApiResponse<T>> postParsed<T>(
    String path, {
    dynamic data,
    T Function(Object? json)? fromJsonT,
  }) async {
    final response = await post(path, data: data);
    return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJsonT);
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await _connectivity.hasConnection();
    if (kDebugMode && !hasConnection) {
      if (kDebugMode) {
        print('CONNECTIVITY CHECK: No internet detected by connectivity_plus');
      }
    }
    if (!hasConnection) {
      throw const NetworkFailure();
    }
  }

  void close() {
    _dio.close();
  }
}
