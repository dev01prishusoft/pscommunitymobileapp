import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/razorpay_order.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaymentDashboard> getDashboard() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentDashboard);
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] != true) {
        throw Exception(json['message'] ?? 'Failed to load dashboard');
      }
      
      final data = json['data'] as Map<String, dynamic>;
      return PaymentDashboard.fromJson(data);
    } catch (e, stack) {
      AppLogger.e('GetDashboard Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentType>> getPaymentTypes() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentTypes);
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] != true) return [];
      
      final data = json['data'] as List? ?? [];
      return data.map((e) => PaymentType.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.e('GetPaymentTypes Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentCategory>> getCategories(int paymentTypeId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.paymentCategories,
        queryParameters: {'paymentTypeId': paymentTypeId},
      );
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] != true) return [];
      
      final data = json['data'] as List? ?? [];
      return data.map((e) => PaymentCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.e('GetCategories Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<RazorpayOrder> createOrder({
    required double amount,
    required int paymentTypeId,
    required int paymentCategoryId,
    int? adminPaymentRequestId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: {
          'amount': amount,
          'paymentTypeId': paymentTypeId,
          'paymentCategoryId': paymentCategoryId,
          if (adminPaymentRequestId != null) 'adminPaymentRequestId': adminPaymentRequestId,
        },
      );
      
      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) {
        throw Exception(json['message'] ?? 'Failed to create order');
      }
      
      final data = json['data'] as Map<String, dynamic>;
      return RazorpayOrder.fromJson(data);
    } catch (e, stack) {
      AppLogger.e('CreateOrder Error', e, stack);
      rethrow;
    }
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
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyPayment,
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
          'amount': amount,
          'paymentTypeId': paymentTypeId,
          'paymentCategoryId': paymentCategoryId,
          if (adminPaymentRequestId != null) 'adminPaymentRequestId': adminPaymentRequestId,
        },
      );
      
      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) {
        throw Exception(json['message'] ?? 'Payment verification failed');
      }
      
      return json['data'] as Map<String, dynamic>? ?? {};
    } catch (e, stack) {
      AppLogger.e('VerifyPayment Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentItem>> getHistory({
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (paymentTypeId != null) 'paymentTypeId': paymentTypeId,
        if (categoryId != null) 'categoryId': categoryId,
        if (year != null) 'year': year,
        if (status != null && status != 'All') 'status': status,
      };

      final response = await _apiClient.get(
        ApiEndpoints.paymentHistory,
        queryParameters: queryParameters,
      );
      
      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) return [];
      
      final data = json['data'] as List? ?? [];
      return data.map((e) => PaymentItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.e('GetHistory Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getReceipt(int receiptId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.paymentReceipt}/$receiptId');
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] != true) {
        throw Exception(json['message'] ?? 'Failed to load receipt');
      }
      
      return json['data'] as Map<String, dynamic>? ?? {};
    } catch (e, stack) {
      AppLogger.e('GetReceipt Error', e, stack);
      rethrow;
    }
  }
}
