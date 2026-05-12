import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class MockLoginUseCase implements LoginUseCase {
  bool shouldThrow = false;

  @override
  Future<AuthTokens> call({required String mobile, required String password}) async {
    if (shouldThrow) throw ServerFailure('Invalid credentials');
    return AuthTokens(accessToken: 'access', refreshToken: 'refresh', isDefaultPassword: false);
  }
}

class MockTokenManager implements TokenManager {
  String? savedAccess;
  String? savedRefresh;
  
  @override
  Future<void> saveTokens(String access, String refresh) async {
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
  late MockTokenManager mockTokenManager;
  late MockSamajController mockSamajController;

  setUp(() {
    mockUseCase = MockLoginUseCase();
    mockTokenManager = MockTokenManager();
    mockSamajController = MockSamajController();
    Get.put<SamajController>(mockSamajController);
    controller = LoginController(mockUseCase, mockTokenManager);
  });

  tearDown(() {
    Get.reset();
  });

  test('isLoading lifecycle, token save, and navigation on success', () async {
    expect(controller.isLoading.value, false);
    
    final future = controller.login(mobile: '123', password: 'password');
    expect(controller.isLoading.value, true);
    
    final result = await future;
    
    expect(controller.isLoading.value, false);
    expect(result, isNotNull);
    expect(mockTokenManager.savedAccess, 'access');
    expect(mockSamajController.fetchCalled, true);
  });

  test('error propagation and AppState reset on failure', () async {
    mockUseCase.shouldThrow = true;
    
    final result = await controller.login(mobile: '123', password: 'wrong');
    
    expect(controller.isLoading.value, false);
    expect(result, isNull);
    expect(controller.error.value, 'Invalid credentials');
  });
}
