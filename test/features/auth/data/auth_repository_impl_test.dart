import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/auth/data/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class MockApiClient implements ApiClient {
  Response? mockResponse;
  
  @override
  Future<Response> post(String path, {data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return mockResponse!;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = AuthRepositoryImpl(mockApiClient);
  });

  test('login success path returns AuthTokens', () async {
    mockApiClient.mockResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        'succeeded': true,
        'data': {
          'accessToken': 'token123',
          'refreshToken': 'refresh123',
          'isDefaultPassword': false,
        }
      }
    );

    final result = await repository.login(mobile: '123', password: 'pw');
    expect(result.accessToken, 'token123');
    expect(result.refreshToken, 'refresh123');
    expect(result.isDefaultPassword, false);
  });

  test('login throws ServerFailure when succeeded: false', () async {
    mockApiClient.mockResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        'succeeded': false,
        'message': 'Invalid credentials provided',
      }
    );

    expect(
      () => repository.login(mobile: '123', password: 'pw'),
      throwsA(isA<ServerFailure>().having((f) => f.message, 'message', 'Invalid credentials provided'))
    );
  });

  test('login throws ServerFailure when tokens are missing', () async {
    mockApiClient.mockResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        'succeeded': true,
        'data': {
          'accessToken': '',
          'refreshToken': '',
        }
      }
    );

    expect(
      () => repository.login(mobile: '123', password: 'pw'),
      throwsA(isA<ServerFailure>().having((f) => f.message, 'message', 'Response is missing authentication tokens'))
    );
  });
}
