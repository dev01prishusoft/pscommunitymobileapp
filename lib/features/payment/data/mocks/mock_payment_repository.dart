import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/razorpay_order.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_request.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/paid_payment_request.dart';

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<PaymentDashboard> getDashboard() async {
    AppLogger.i('Mock: getDashboard');
    return PaymentDashboard(
      totalDue: 1500.0,
      pendingPayments: [
        PaymentRequest(
          id: 1,
          title: 'Annual Membership 2025',
          amount: 1000.0,
          amountFormatted: '₹1000',
          dueDate: '15 Mar 2025',
          dueDateRaw: '2025-03-15',
          icon: 'membership',
          paymentTypeId: 1,
          paymentCategoryId: 1,
        ),
        PaymentRequest(
          id: 2,
          title: 'Samaj Bhavan Donation',
          amount: 500.0,
          amountFormatted: '₹500',
          dueDate: '01 Apr 2025',
          dueDateRaw: '2025-04-01',
          icon: 'temple',
          paymentTypeId: 2,
          paymentCategoryId: 5,
        ),
      ],
      paidPayments: [
        PaidPaymentRequest(
          id: 101,
          title: 'Annual Membership 2024',
          amountFormatted: '₹1000',
          paidDate: '10 Jan 2024',
          receiptId: 5001,
        ),
      ],
    );
  }

  @override
  Future<List<PaymentType>> getPaymentTypes() async {
    AppLogger.i('Mock: getPaymentTypes');
    return [
      PaymentType(id: 1, name: 'Membership'),
      PaymentType(id: 2, name: 'Donation'),
      PaymentType(id: 3, name: 'Event Fee'),
    ];
  }

  @override
  Future<List<PaymentCategory>> getCategories(int paymentTypeId) async {
    AppLogger.i('Mock: getCategories for $paymentTypeId');
    if (paymentTypeId == 1) {
      return [
        PaymentCategory(id: 1, name: 'Family Membership', defaultAmount: 1000),
        PaymentCategory(id: 2, name: 'Individual Membership', defaultAmount: 500),
      ];
    }
    return [
      PaymentCategory(id: 5, name: 'General Donation', defaultAmount: 0),
      PaymentCategory(id: 6, name: 'Educational Fund', defaultAmount: 0),
    ];
  }

  @override
  Future<RazorpayOrder> createOrder({
    required double amount,
    required int paymentTypeId,
    required int paymentCategoryId,
    int? adminPaymentRequestId,
  }) async {
    AppLogger.i('Mock: createOrder');
    return RazorpayOrder(
      orderId: 'order_mock_${DateTime.now().millisecondsSinceEpoch}',
      amountInPaise: (amount * 100).toInt(),
      currency: 'INR',
      keyId: 'mock_key',
    );
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required double amount,
    required int paymentTypeId,
    required int paymentCategoryId,
    int? adminPaymentRequestId,
  }) async {
    AppLogger.i('Mock: verifyPayment');
    return {
      'succeeded': true,
      'message': 'Payment verified successfully (Mock)',
      'receiptId': 9999,
    };
  }

  @override
  Future<List<PaymentItem>> getHistory({
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
  }) async {
    AppLogger.i('Mock: getHistory');
    return [];
  }

  @override
  Future<Map<String, dynamic>> getReceipt(int receiptId) async {
    AppLogger.i('Mock: getReceipt');
    return {
      'receiptNo': 'RCP-9999',
      'date': '11 May 2026',
      'name': '',
      'memberNo': '',
      'type': 'Membership',
      'category': 'Family Membership',
      'amount': '₹1000',
      'mode': 'Razorpay Online',
      'status': 'Success',
      'transactionId': 'pay_mock_123456789',
    };
  }
}
