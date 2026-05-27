import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_mode.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/razorpay_order.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaymentDashboard> getDashboard() async {
    try {
      final response = await _apiClient.getParsed<PaymentDashboard>(
        ApiEndpoints.paymentDashboard,
        fromJsonT: (json) =>
            PaymentDashboard.fromJson(json as Map<String, dynamic>),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull!.data!;
    } catch (e, stack) {
      AppLogger.e('GetDashboard Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentMode>> getPaymentModes() async {
    try {
      final response = await _apiClient.getParsed<List<PaymentMode>>(
        ApiEndpoints.paymentModes,
        fromJsonT: (json) => (json as List)
            .map((e) => PaymentMode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetPaymentModes Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentType>> getPaymentTypes() async {
    try {
      final response = await _apiClient.getParsed<List<PaymentType>>(
        ApiEndpoints.paymentTypes,
        fromJsonT: (json) => (json as List)
            .map((e) => PaymentType.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetPaymentTypes Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<PaymentCategory>> getCategories(int paymentTypeId) async {
    try {
      final response = await _apiClient.getParsed<List<PaymentCategory>>(
        ApiEndpoints.paymentCategories,
        queryParameters: {'paymentTypeId': paymentTypeId},
        fromJsonT: (json) => (json as List)
            .map((e) => PaymentCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? [];
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
    String currency = 'INR',
    int memberId = 0,
    int paymentStatusId = 0,
    int paymentModeId = 0,
    String? description,
  }) async {
    try {
      final response = await _apiClient.postParsed<RazorpayOrder>(
        ApiEndpoints.createOrder,
        data: {
          'amount': amount,
          'currency': currency,
          'paymentTypeId': paymentTypeId,
          'paymentCategoryId': paymentCategoryId,
          'adminPaymentRequestId': adminPaymentRequestId ?? 0,
          'memberId': memberId,
          'paymentStatusId': paymentStatusId,
          'paymentModeId': paymentModeId,
          'description': description ?? "",
        },
        fromJsonT: (json) =>
            RazorpayOrder.fromJson(json as Map<String, dynamic>),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull!.data!;
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
      final response = await _apiClient.postParsed<Map<String, dynamic>>(
        ApiEndpoints.verifyPayment,
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
          'amount': amount,
          'paymentTypeId': paymentTypeId,
          'paymentCategoryId': paymentCategoryId,
          if (adminPaymentRequestId != null)
            'adminPaymentRequestId': adminPaymentRequestId,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? {};
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
        if (paymentTypeId != null) 'PaymentTypeId': paymentTypeId,
        if (categoryId != null) 'CategoryId': categoryId,
        if (year != null) 'Year': year,
        if (status != null && status != 'All') 'Status': status,
      };

      final response = await _apiClient.getParsed<List<PaymentItem>>(
        ApiEndpoints.paymentHistory,
        queryParameters: queryParameters,
        fromJsonT: (json) => (json as List)
            .map((e) => PaymentItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetHistory Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getReceipt(int receiptId) async {
    try {
      final response = await _apiClient.getParsed<Map<String, dynamic>>(
        '${ApiEndpoints.paymentReceipt}/$receiptId',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      if (response.isFailure) throw response.failureOrNull!;
      return response.dataOrNull?.data ?? {};
    } catch (e, stack) {
      AppLogger.e('GetReceipt Error', e, stack);
      rethrow;
    }
  }
}
