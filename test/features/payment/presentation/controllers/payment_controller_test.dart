import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:flutter/services.dart';

import 'payment_controller_test.mocks.dart';

@GenerateMocks([PaymentRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPaymentRepository mockRepository;
  late PaymentController controller;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('razorpay_flutter'),
            (MethodCall methodCall) async {
      return null;
    });

    mockRepository = MockPaymentRepository();
    when(mockRepository.getDashboard()).thenAnswer(
        (_) async => PaymentDashboard(totalDue: 0, pendingPayments: [], paidPayments: []));
    when(mockRepository.getPaymentTypes()).thenAnswer((_) async => []);
    controller = PaymentController(mockRepository);
  });

  tearDown(() {
    if (Get.isRegistered<PaymentController>()) {
      Get.delete<PaymentController>();
    }
  });

  test('initial state is correct', () {
    expect(controller.dashboardState.value, AppState.loading);
    expect(controller.paymentTypes, isEmpty);
    expect(controller.categories, isEmpty);
  });

  test('loadDashboard updates state correctly on success', () async {
    Get.put(controller);
    final dashboard = PaymentDashboard(totalDue: 100, pendingPayments: [], paidPayments: []);
    when(mockRepository.getDashboard()).thenAnswer((_) async => dashboard);

    await controller.loadDashboard();

    expect(controller.dashboardState.value, AppState.data);
    expect(controller.dashboard.value, dashboard);
  });

  test('loadDashboard updates state correctly on error', () async {
    // We don't call Get.put(controller) here so onInit is not called automatically.
    controller.dashboard.value = null; // Clear from onInit
    when(mockRepository.getDashboard()).thenThrow(Exception('Error'));

    await controller.loadDashboard();

    expect(controller.dashboardState.value, AppState.error);
    expect(controller.dashboard.value, isNull);
  });

  test('onTypeChanged fetches categories and resets selected category', () async {
    Get.put(controller);
    final type = PaymentType(id: 1, name: 'Donation');
    final category = PaymentCategory(id: 1, name: 'General', defaultAmount: 500);
    when(mockRepository.getCategories(1)).thenAnswer((_) async => [category]);

    await controller.onTypeChanged(type);

    expect(controller.selectedType.value, type);
    expect(controller.selectedCategory.value, isNull);
    expect(controller.enteredAmount.value, 0.0);
    expect(controller.categories.length, 1);
    expect(controller.categories.first, category);
  });

  test('onCategoryChanged updates amount', () {
    Get.put(controller);
    final category = PaymentCategory(id: 1, name: 'General', defaultAmount: 1000);
    
    controller.onCategoryChanged(category);

    expect(controller.selectedCategory.value, category);
    expect(controller.enteredAmount.value, 1000.0);
  });
}
