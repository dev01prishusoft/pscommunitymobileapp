import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class MockLoginUseCase implements LoginUseCase {
  bool shouldThrow = false;

  @override
  Future<Result<AuthTokens>> call({
    required String mobile,
    required String password,
  }) async {
    if (shouldThrow) return Error(ServerFailure('Some generic error'));
    return Success(AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      isDefaultPassword: false,
    ));
  }
}

class MockTokenManager implements TokenManager {
  String? savedAccess;
  String? savedRefresh;

  @override
  Future<void> saveTokens(String access, String refresh, {bool isDefaultPassword = false, String? mobile}) async {
    savedAccess = access;
    savedRefresh = refresh;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSamajController extends GetxController implements SamajController {
  bool fetchCalled = false;
  @override
  Future<void> fetchSamajDetail() async {
    fetchCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late LoginController controller;
  late MockLoginUseCase mockUseCase;
  late MockSamajController mockSamajController;

  setUp(() {
    mockUseCase = MockLoginUseCase();
    mockSamajController = MockSamajController();
    Get.put<SamajController>(mockSamajController);
    controller = LoginController(mockUseCase);
  });

  tearDown(() {
    Get.reset();
  });

  test('isLoading lifecycle, token save, and navigation on success', () async {
    expect(controller.isFormLoading, false);

    controller.submit(
      formKey: GlobalKey<FormState>(),
      mobile: '123',
      password: 'password',
    );
    expect(controller.isFormLoading, false);
  });

  test('error propagation and AppState reset on failure', () async {
    mockUseCase.shouldThrow = true;

    controller.submit(
      formKey: GlobalKey<FormState>(),
      mobile: '123',
      password: 'wrong',
    );

    expect(controller.isFormLoading, false);
  });
}
