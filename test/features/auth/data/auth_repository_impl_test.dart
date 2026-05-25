import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/auth/data/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';

class MockApiClient implements ApiClient {
  Response<dynamic>? mockResponse;

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    return mockResponse!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTokenManager implements TokenManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = AuthRepositoryImpl(mockApiClient, MockTokenManager());
  });

  test('login success path returns AuthTokens', () async {
    mockApiClient.mockResponse = Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: {
        'succeeded': true,
        'data': {
          'accessToken': 'token123',
          'refreshToken': 'refresh123',
          'isDefaultPassword': false,
        },
      },
    );

    final result = await repository.login(mobile: '123', password: 'pw');
    expect(result.isSuccess, true);
    final data = result.dataOrNull!;
    expect(data.accessToken, 'token123');
    expect(data.refreshToken, 'refresh123');
    expect(data.isDefaultPassword, false);
  });

  test('login returns ServerFailure when succeeded: false', () async {
    mockApiClient.mockResponse = Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: {'succeeded': false, 'message': 'Invalid credentials provided'},
    );

    final result = await repository.login(mobile: '123', password: 'pw');
    expect(result.isFailure, true);
    expect(result.failureOrNull?.message, 'Invalid credentials provided');
  });

  test('login returns ServerFailure when tokens are missing', () async {
    mockApiClient.mockResponse = Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: {
        'succeeded': true,
        'data': {'accessToken': '', 'refreshToken': ''},
      },
    );

    final result = await repository.login(mobile: '123', password: 'pw');
    expect(result.isFailure, true);
    expect(result.failureOrNull?.message, 'Response is missing authentication tokens');
  });
}
