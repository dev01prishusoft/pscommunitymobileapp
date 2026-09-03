import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/coupon_apply_model.dart';
import 'package:pscommunitymobileapp/core/models/event_create_order_model.dart';
import 'package:pscommunitymobileapp/core/models/event_validate_model.dart';
import 'package:pscommunitymobileapp/core/models/gender_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';

abstract class EventsRepositories {
  Future<Result<PaginatedResponse<EventsData>>> getEvents({
    String? searchQuery,
    String type,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<EventDetailsData>>> getEventDetails({
    required int id,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<CouponApplyData>>> applyCoupon({
    required int eventId,
    required int memberId,
    required String couponCode,
    required int guestCount,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<List<GenderData>>>> getGenderDropdown({
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<EventValidateData>>> eventValidator({
    required int eventId,
    required int memberId,
    required List<Map<String, dynamic>> guests,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<CreateOrderData>>> eventCreateorder({
    required int eventId,
    required int memberId,
    required int eventCouponId,
    required int guestCount,
    CancelToken? cancelToken,
  });

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
  });

  Future<Result<ApiResponse<Map<String, dynamic>>>> eventFreeRegister({
    required int eventId,
    required int memberId,
    String? notes,
    required List<Map<String, dynamic>> guests,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<RegisteredEventData>>> getMyRegisteredEvents({
    int page = 1,
    int pageSize = 10,
    CancelToken? cancelToken,
  });
}
