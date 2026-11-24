import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/network/auth_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/network/error_mapping_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/language_interceptor.dart';
import 'package:pscommunitymobileapp/core/network/network_exception_mapper.dart';
import 'package:pscommunitymobileapp/core/network/retry_interceptor.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';

class ApiClient {
  ApiClient({
    required TokenManager tokenManager,
    required ConnectivityService connectivity,
    required VoidCallback onAuthFailure,
  }) : connectivity = connectivity,
       _dio = Dio(
         BaseOptions(
           baseUrl: AppEnvironment.I.apiBaseUrl,
           connectTimeout: AppEnvironment.I.connectTimeout,
           receiveTimeout: AppEnvironment.I.receiveTimeout,
         ),
       ),
       _refreshDio = Dio(BaseOptions(baseUrl: AppEnvironment.I.apiBaseUrl)) {
    _refreshDio.interceptors.add(
      RetryInterceptor(dio: _refreshDio, maxRetries: 3),
    );

    _dio.interceptors.addAll([
      LanguageInterceptor(),
      AuthInterceptor(
        tokenManager: tokenManager,
        refreshDio: _refreshDio,
        mainDio: _dio,
        onAuthFailure: onAuthFailure,
      ),
      RetryInterceptor(dio: _dio, maxRetries: 3),
      ErrorMappingInterceptor(),
    ]);
  }
  final Dio _dio;
  final Dio _refreshDio;
  final ConnectivityService connectivity;

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    _refreshDio.options.baseUrl = newBaseUrl;
  }

  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: (options ?? Options()).copyWith(method: method),
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
    return request(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request(
      path,
      method: 'POST',
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return request(path, method: 'PUT', data: data, cancelToken: cancelToken);
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return request(
      path,
      method: 'DELETE',
      data: data,
      cancelToken: cancelToken,
    );
  }

  Future<Result<ApiResponse<T>>> getParsed<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final response = await get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return Success(
        ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          fromJsonT,
        ),
      );
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
      final response = await get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return Success(
        PaginatedResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          listKey,
          fromJsonT,
        ),
      );
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  Future<Result<ApiResponse<T>>> postParsed<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) async {
    try {
      final response = await post(
        path,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return Success(
        ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          fromJsonT,
        ),
      );
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
      return Success(
        ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          fromJsonT,
        ),
      );
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  void close() {
    _dio.close();
  }
}
