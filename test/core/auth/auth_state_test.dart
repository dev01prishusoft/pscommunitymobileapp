import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';

import 'auth_state_test.mocks.dart';

class FakeSamajController extends GetxController implements SamajController {
  bool clearCalled = false;
  @override
  void clear() {
    clearCalled = true;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@GenerateNiceMocks([MockSpec<TokenManager>(), MockSpec<LocalizationService>()])
void main() {
  late MockTokenManager mockTokenManager;
  late AuthState authState;

  setUp(() {
    mockTokenManager = MockTokenManager();
    when(mockTokenManager.authState).thenReturn(Rx<TokenPair>(TokenPair()));
    when(mockTokenManager.hasToken).thenReturn(false);
    
    authState = AuthState(mockTokenManager);
  });

  tearDown(() {
    Get.reset();
  });

  test('isAuthenticated reflects TokenManager hasToken state', () {
    when(mockTokenManager.hasToken).thenReturn(true);
    final newState = AuthState(mockTokenManager);
    expect(newState.isAuthenticated.value, isTrue);
  });



  test('logout clears tokens and dependencies', () {
    final fakeSamaj = FakeSamajController();
    final mockLoc = MockLocalizationService();
    
    Get.put<SamajController>(fakeSamaj);
    Get.put<LocalizationService>(mockLoc);
    
    authState.logout();
    
    verify(mockTokenManager.clearTokens()).called(1);
    expect(fakeSamaj.clearCalled, isTrue);
    verify(mockLoc.changeLocale('en', 'US')).called(1);
  });
}
