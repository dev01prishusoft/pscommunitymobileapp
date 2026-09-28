import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/event_attendance_repository.dart';

class EventAttendanceRepositoryImpl implements EventAttendanceRepository {
  EventAttendanceRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<ApiResponse<Map<String, dynamic>>>> scanEventBarcode({
    required String qrData,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.scanEventBarcode,
      data: {"qrData": qrData},
      cancelToken: cancelToken,
      options: Options(headers: {"Content-Type": "application/json"}),
      fromJsonT: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  @override
  Future<Result<ApiResponse<Map<String, dynamic>>>> checkInEventByQr({
    required int eventId,
    required int eventRegistrationId,
    required int memberId,
    required int numberOfUsers,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.checkInEventByQr,
      data: {
        "eventId": eventId,
        "eventRegistrationId": eventRegistrationId,
        "memberId": memberId,
        "numberOfUsers": numberOfUsers,
      },
      cancelToken: cancelToken,
      options: Options(headers: {"Content-Type": "application/json"}),
      fromJsonT: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }
}
