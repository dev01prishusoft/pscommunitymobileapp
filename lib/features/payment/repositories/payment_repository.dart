import 'package:pscommunitymobileapp/core/models/payment_item.dart';
import 'package:pscommunitymobileapp/core/models/payment_type.dart';
import 'package:pscommunitymobileapp/core/models/payment_category.dart';
import 'package:pscommunitymobileapp/core/models/razorpay_order.dart';
import 'package:pscommunitymobileapp/core/models/payment_dashboard.dart';

import 'package:pscommunitymobileapp/core/models/payment_mode.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';

abstract class PaymentRepository {
  Future<List<Map<String, dynamic>>> getPaymentStatuses();
  Future<PaymentDashboard> getDashboard();
  Future<List<PaymentMode>> getPaymentModes();
  Future<List<PaymentType>> getPaymentTypes();
  Future<List<PaymentCategory>> getCategories(int paymentTypeId);
  Future<RazorpayOrder> createOrder({
    required double amount,
    required int paymentTypeId,
    required int paymentCategoryId,
    int? adminPaymentRequestId,
    String currency = 'INR',
    int memberId = 0,
    int paymentStatusId = 0,
    int paymentModeId = 0,
    String? description,
    bool isRecurring = false,
  });
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required double amount,
    required int paymentTypeId,
    required int paymentCategoryId,
    int? adminPaymentRequestId,
    bool isRecurring = false,
  });
  Future<Result<PaginatedResponse<PaymentItem>>> getHistory({
    int page = 1,
    int pageSize = 20,
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
    String? search,
  });
  Future<Map<String, dynamic>> getReceipt(int receiptId);
}
