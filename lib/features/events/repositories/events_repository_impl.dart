import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/coupon_apply_model.dart';
import 'package:pscommunitymobileapp/core/models/event_create_order_model.dart';
import 'package:pscommunitymobileapp/core/models/event_validate_model.dart';
import 'package:pscommunitymobileapp/core/models/gender_model.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class EventsRepositoryImpl implements EventsRepositories {
  EventsRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<PaginatedResponse<EventsData>>> getEvents({
    String? searchQuery,
    String? type,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> params = {
      'TimePeriod': type,
      'Page': pageNumber,
      'PageSize': pageSize,
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['Search'] = searchQuery;
    }

    return await _apiClient.getPaginated<EventsData>(
      ApiEndpoints.eventList,
      queryParameters: params,
      cancelToken: cancelToken,
      listKey: 'data',
      fromJsonT: (json) => EventsData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<EventDetailsData>>> getEventDetails({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getParsed<EventDetailsData>(
      ApiEndpoints.eventDetails(id),
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          EventDetailsData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<EventValidateData>>> eventValidator({
    required int eventId,
    required int memberId,
    required List<Map<String, dynamic>> guests,
    CancelToken? cancelToken,
  }) async {
    print({"eventId": eventId, "memberId": memberId, "guests": guests});
    return await _apiClient.postParsed<EventValidateData>(
      ApiEndpoints.EventRegistrationValdiate,
      data: {"eventId": eventId, "memberId": memberId, "guests": guests},
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          EventValidateData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<CouponApplyData>>> applyCoupon({
    required int eventId,
    required int memberId,
    required String couponCode,
    required int guestCount,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<CouponApplyData>(
      ApiEndpoints.applyCoupon,
      data: {
        "eventId": eventId,
        "memberId": memberId,
        "couponCode": couponCode,
        "guestCount": guestCount,
      },
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          CouponApplyData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<List<GenderData>>>> getGenderDropdown({
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getParsed<List<GenderData>>(
      ApiEndpoints.genderDropdown,
      cancelToken: cancelToken,
      fromJsonT: GenderData.listFromJson,
    );
  }

  @override
  Future<Result<ApiResponse<CreateOrderData>>> eventCreateorder({
    required int eventId,
    required int memberId,
    required int eventCouponId,
    required int guestCount,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<CreateOrderData>(
      ApiEndpoints.eventCreateOrder,
      data: {
        "eventId": eventId,
        "memberId": memberId,
        "eventCouponId": eventCouponId,
        "guestCount": guestCount,
      },
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          CreateOrderData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<Map<String, dynamic>>>> eventVerifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int eventId,
    required int memberId,
    int? eventCouponId,
    String? notes,
    required List<Map<String, dynamic>> guests,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.eventVerifyPayment,
      data: {
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "eventId": eventId,
        "memberId": memberId,
        "eventCouponId": (eventCouponId != null && eventCouponId > 0)
            ? eventCouponId
            : null,
        "notes": notes ?? "",
        "guests": guests,
      },
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  @override
  Future<Result<ApiResponse<Map<String, dynamic>>>> eventFreeRegister({
    required int eventId,
    required int memberId,
    String? notes,
    required List<Map<String, dynamic>> guests,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.eventFreeRegister,
      data: {
        "eventRegistrationId": null,
        "eventId": eventId,
        "memberId": memberId,
        "paymentId": null,
        "eventCouponId": null,
        "notes": notes ?? "",
        "guests": guests,
      },
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  @override
  Future<Result<ApiResponse<RegisteredEventsData>>> getMyRegisteredEvents({
    int page = 1,
    int pageSize = 10,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<RegisteredEventsData>(
      ApiEndpoints.myRegisteredEvents,
      data: {"Page": page, "PageSize": pageSize},
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          RegisteredEventsData.fromJson(json as Map<String, dynamic>),
    );
  }
}
