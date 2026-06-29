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
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

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
    bool isRecurring = false,
  }) async {
    try {
      final payload = {
        'amount': amount,
        'currency': currency,
        'paymentTypeId': paymentTypeId,
        'paymentCategoryId': paymentCategoryId,
        'adminPaymentRequestId': adminPaymentRequestId ?? 0,
        'memberId': memberId,
        'paymentStatusId': paymentStatusId,
        'paymentModeId': paymentModeId,
        'description': description ?? '',
        'isRecurring': isRecurring,
      };
      AppLogger.i('CreateOrder Payload: $payload');

      final response = await _apiClient.postParsed<RazorpayOrder>(
        ApiEndpoints.createOrder,
        data: payload,
        fromJsonT: (json) =>
            RazorpayOrder.fromJson(json as Map<String, dynamic>),
      );
      
      AppLogger.i('CreateOrder Response Status: ${response.isFailure ? "Failure" : "Success"}');
      
      if (response.isFailure) {
        AppLogger.e('CreateOrder Failed - Message: ${response.failureOrNull?.message}');
        throw response.failureOrNull!;
      }
      
      AppLogger.i('CreateOrder Success Data: ${response.dataOrNull?.data}');
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
    bool isRecurring = false,
  }) async {
    try {
      final endpoint = isRecurring ? ApiEndpoints.verifySubscription : ApiEndpoints.verifyPayment;
      
      final Map<String, dynamic> payload;
      if (isRecurring) {
        payload = {
          'paymentId': adminPaymentRequestId ?? 0,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySubscriptionId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
        };
      } else {
        payload = {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
          'amount': amount,
          'paymentTypeId': paymentTypeId,
          'paymentCategoryId': paymentCategoryId,
          if (adminPaymentRequestId != null)
            'adminPaymentRequestId': adminPaymentRequestId,
        };
      }

      AppLogger.i('VerifyPayment API Endpoint: $endpoint');
      AppLogger.i('VerifyPayment API Payload: $payload');

      final response = await _apiClient.postParsed<Map<String, dynamic>>(
        endpoint,
        data: payload,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      AppLogger.i('VerifyPayment API Raw Status: ${response.isSuccess ? 'Success' : 'Failure'}');

      if (response.isFailure) {
        AppLogger.e('VerifyPayment API Failed - Message: ${response.failureOrNull?.message}');
        throw response.failureOrNull!;
      }
      
      AppLogger.i('VerifyPayment API Success Response: ${response.dataOrNull?.data}');
      return response.dataOrNull?.data ?? {};
    } catch (e, stack) {
      AppLogger.e('VerifyPayment Error', e, stack);
      rethrow;
    }
  }

  @override
  Future<Result<PaginatedResponse<PaymentItem>>> getHistory({
    int page = 1,
    int pageSize = 20,
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'Page': page,
        'PageSize': pageSize,
        if (paymentTypeId != null) 'paymentTypeId': paymentTypeId,
        if (categoryId != null) 'paymentCategoryId': categoryId,
        if (year != null) 'year': year,
        if (status != null && status != 'All') 'paymentStatus': status,
      };

      return await _apiClient.getPaginated<PaymentItem>(
        ApiEndpoints.paymentHistory,
        listKey: 'data',
        queryParameters: queryParameters,
        fromJsonT: (json) => PaymentItem.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      AppLogger.e('GetHistory Error', e, stack);
      return Error(e is Failure ? e : ServerFailure(e.toString()));
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
