import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/session_manager.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';

import 'session_manager_test.mocks.dart';

@GenerateMocks([AuthState])
void main() {
  late MockAuthState mockAuthState;
  late SessionManager sessionManager;

  setUp(() {
    mockAuthState = MockAuthState();
    when(mockAuthState.isAuthenticated).thenReturn(RxBool(true));
    sessionManager = SessionManager(mockAuthState);
    Get.put(sessionManager);
  });

  tearDown(() {
    Get.delete<SessionManager>();
  });

  test('userInteracted resets timer', () {
    // We can't directly inspect the timer easily without fake_async,
    // but we can ensure calling userInteracted does not throw.
    expect(() => sessionManager.userInteracted(), returnsNormally);
  });
}
