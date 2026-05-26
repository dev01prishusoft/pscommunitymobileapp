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
import 'package:pscommunitymobileapp/core/network/network_exception_mapper.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ApiClient {
  ApiClient({
    required TokenManager tokenManager,
    required ConnectivityService connectivity,
    required VoidCallback onAuthFailure,
  }) : _connectivity = connectivity,
       _dio = Dio(
         BaseOptions(
           baseUrl: AppEnvironment.I.apiBaseUrl,
           connectTimeout: AppEnvironment.I.connectTimeout,
           receiveTimeout: AppEnvironment.I.receiveTimeout,
         ),
       ) {
    final refreshDio = Dio(BaseOptions(baseUrl: AppEnvironment.I.apiBaseUrl));

    CertificatePinning.configure(_dio);
    CertificatePinning.configure(refreshDio);

    if (AppEnvironment.I.enableLogging) {
      refreshDio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          compact: true,
          logPrint: (Object object) {
            AppLogger.d(object.toString());
          },
        ),
      );
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
          logPrint: (Object object) {
            AppLogger.d(object.toString());
          },
        ),
    ]);
  }
  final Dio _dio;
  final ConnectivityService _connectivity;

  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(method: method),
      );
    } catch (e) {
      throw NetworkExceptionMapper.map(e);
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return request(path, method: 'GET', queryParameters: queryParameters, cancelToken: cancelToken);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return request(path, method: 'POST', data: data, cancelToken: cancelToken);
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return request(path, method: 'PUT', data: data, cancelToken: cancelToken);
  }

  Future<Result<ApiResponse<T>>> getParsed<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final response = await get(path, queryParameters: queryParameters, cancelToken: cancelToken);
      return Success(ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT,
      ));
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  Future<Result<PaginatedResponse<T>>> getPaginated<T>(
    String path, {
    required String listKey,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await get(path, queryParameters: queryParameters, cancelToken: cancelToken);
      return Success(PaginatedResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        listKey,
        fromJsonT,
      ));
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  Future<Result<ApiResponse<T>>> postParsed<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final response = await post(path, data: data, cancelToken: cancelToken);
      return Success(ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT,
      ));
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  Future<Result<ApiResponse<T>>> putParsed<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final response = await put(path, data: data, cancelToken: cancelToken);
      return Success(ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT,
      ));
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await _connectivity.hasConnection();
    if (kDebugMode && !hasConnection) {
      if (kDebugMode) {}
    }
    if (!hasConnection) {
      throw NetworkFailure();
    }
  }

  void close() {
    _dio.close();
  }
}
