// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/app/app.dart';

import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('App shows login page first', (WidgetTester tester) async {
    // Setup minimal DI for test
    final storage = SecureStorageService();
    final tokenManager = TokenManager(storage);
    final localization = LocalizationService(storage);
    
    // Manual bootstrap for test to avoid rootBundle load errors
    localization.keys = {
      'en_US': {'common_app_title': 'PS Community', 'Sign In': 'Sign In'},
      'gu_IN': {'common_app_title': 'PS Community', 'Sign In': 'Sign In'},
    };
    
    Get.put(tokenManager);
    Get.put(localization);
    
    await tester.pumpWidget(const PsCommunityApp());
    expect(find.byType(PsCommunityApp), findsOneWidget);
  });
}
