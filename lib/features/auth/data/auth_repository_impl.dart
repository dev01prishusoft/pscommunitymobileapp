import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._tokenManager);
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  @override
  Future<Result<AuthTokens>> login({
    required String mobile,
    required String password,
  }) async {
    final result = await _apiClient.postParsed<AuthTokens>(
      ApiEndpoints.login,
      data: {'mobile': mobile, 'password': password},
      fromJsonT: (json) => _mapAuthResponseData(json as Map<String, dynamic>),
    );
    
    if (result is Success<ApiResponse<AuthTokens>>) {
      final tokens = result.data.data;
      if (tokens == null) {
        return Error(ServerFailure('Missing tokens in response'));
      }
      await _tokenManager.saveTokens(
        tokens.accessToken, 
        tokens.refreshToken,
        isDefaultPassword: tokens.isDefaultPassword,
        mobile: mobile,
        deviceUniqueId: tokens.deviceUniqueId,
        primaryColor: tokens.primaryColor,
        secondaryColor: tokens.secondaryColor,
      );
      return Success(tokens);
    } else {
      return Error((result as Error).failure);
    }
  }

  @override
  Future<Result<AuthTokens>> memberLogin({
    required String mobile,
    required String password,
  }) async {
    String deviceType = 'unknown';
    String deviceToken = '';
    try {
      if (kIsWeb) {
        deviceType = 'web';
      } else if (Platform.isAndroid) {
        deviceType = 'android';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
      }
      deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {}

    final result = await _apiClient.postParsed<AuthTokens>(
      ApiEndpoints.memberLogin,
      data: {
        'mobileNo': mobile, 
        'password': password,
        'deviceToken': deviceToken,
        'deviceType': deviceType,
        'ipAddress': '',
      },
      fromJsonT: (json) => _mapAuthResponseData(json as Map<String, dynamic>),
    );
    
    if (result is Success<ApiResponse<AuthTokens>>) {
      final tokens = result.data.data;
      if (tokens == null) {
        return Error(ServerFailure('Missing tokens in response'));
      }
      await _tokenManager.saveTokens(
        tokens.accessToken, 
        tokens.refreshToken,
        isDefaultPassword: tokens.isDefaultPassword,
        mobile: mobile,
        deviceUniqueId: tokens.deviceUniqueId,
        primaryColor: tokens.primaryColor,
        secondaryColor: tokens.secondaryColor,
      );
      return Success(tokens);
    } else {
      return Error((result as Error).failure);
    }
  }

  @override
  Future<Result<void>> memberUpdatePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
  }) async {
    final result = await _apiClient.postParsed<void>(
      ApiEndpoints.memberUpdatePassword,
      data: {
        'mobileNo': mobileNo,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    
    if (result is Success<ApiResponse<void>>) {
      return const Success(null);
    } else {
      return Error((result as Error).failure);
    }
  }

  @override
  Future<Result<AuthTokens>> memberRefreshToken({required String refreshToken}) async {
    final result = await _apiClient.postParsed<AuthTokens>(
      ApiEndpoints.memberRefreshToken,
      data: {
        'accessToken': _tokenManager.accessToken,
        'refreshToken': refreshToken,
        'mobileNo': _tokenManager.userPhone,
      },
      fromJsonT: (json) => _mapAuthResponseData(json as Map<String, dynamic>),
    );
    
    if (result is Success<ApiResponse<AuthTokens>>) {
      final tokens = result.data.data;
      if (tokens == null) {
        return Error(ServerFailure('Missing tokens in response'));
      }
      return Success(tokens);
    } else {
      return Error((result as Error).failure);
    }
  }

  @override
  Future<Result<void>> memberRevokeToken({required String refreshToken}) async {
    final deviceUniqueId = _tokenManager.authState.value.deviceUniqueId;
    final queryParams = deviceUniqueId != null && deviceUniqueId.isNotEmpty 
        ? '?tokenUniqueId=$deviceUniqueId' 
        : '';
        
    final result = await _apiClient.postParsed<void>(
      '${ApiEndpoints.memberRevokeToken}$queryParams',
      data: '"$refreshToken"',
    );
    
    if (result is Success<ApiResponse<void>>) {
      return const Success(null);
    } else {
      return Error((result as Error).failure);
    }
  }

  AuthTokens _mapAuthResponseData(Map<String, dynamic> authData) {
    final accessToken = authData['accessToken']?.toString() ?? '';
    final refreshToken = authData['refreshToken']?.toString() ?? '';
    final isDefault = authData['isDefaultPassword'] as bool? ?? false;

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ServerFailure('Response is missing authentication tokens');
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isDefaultPassword: isDefault,
      accessTokenExpiry: authData['accessTokenExpiry']?.toString(),
      memberId: authData['memberId'] as int?,
      samajId: authData['samajId'] as int?,
      firstName: authData['firstName']?.toString(),
      middleName: authData['middleName']?.toString(),
      lastName: authData['lastName']?.toString(),
      email: authData['email']?.toString(),
      deviceUniqueId: authData['deviceUniqueId']?.toString(),
      primaryColor: authData['primaryColor']?.toString(),
      secondaryColor: authData['secondaryColor']?.toString(),
    );
  }
}
