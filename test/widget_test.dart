// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/app/app.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    return const AuthTokens(accessToken: 'token', refreshToken: 'refresh');
  }
}

void main() {
  testWidgets('App shows login page first', (WidgetTester tester) async {
    final controller = LoginController(LoginUseCase(_FakeAuthRepository()));

    await tester.pumpWidget(PsCommunityApp(loginController: controller));
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
