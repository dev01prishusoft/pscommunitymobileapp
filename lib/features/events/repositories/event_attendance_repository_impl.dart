import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/event_attendance_repository.dart';

class EventAttendanceRepositoryImpl implements EventAttendanceRepository {
  EventAttendanceRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  /// Temporary custom token for Event Attendance APIs.
  /// Set your token here (e.g. "eyJhbGciOi..."):
  static const String customToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMDA2MyIsImVtYWlsIjoiam9zaGluaWt1bmpAeW9wbWFpbC5jb20iLCJqdGkiOiIxMmM1ODBlNS02OGI4LTRkZWEtYjRkYi1jMDNlOTU0Mzk4NDAiLCJpYXQiOjE3ODg0MTA1MTIsImZpcnN0TmFtZSI6Ik5pa3VuaiIsImxhc3ROYW1lIjoiSm9zaGkiLCJzYW1haklkIjoiMTAwODMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJTYW1haiIsInBlcm1pc3Npb24iOlsiUm9sZXMuRGVsZXRlIiwiUm9sZXMuUmVhZCIsIlJvbGVzLldyaXRlIiwiU3lzdGVtLkFkbWluIiwiU3lzdGVtLkhlYWx0aENoZWNrIiwiU3lzdGVtLlZpZXdMb2dzIiwiVXNlcnMuRGVsZXRlIiwiVXNlcnMuTWFuYWdlUm9sZXMiLCJVc2Vycy5SZWFkIiwiVXNlcnMuV3JpdGUiXSwibmJmIjoxNzg4NDEwNTEyLCJleHAiOjE3ODg0MTQxMTIsImlzcyI6IkVudGVycHJpc2VBcGkiLCJhdWQiOiJFbnRlcnByaXNlQXBpQ2xpZW50cyJ9.SaOolt7WAC30nCHLKYUcUTcf0ycU8IZmt5XJBYVJ9UQ";
  Options? get _tokenOptions {
    if (customToken.trim().isNotEmpty) {
      final token = customToken.trim();
      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      return Options(headers: {'Authorization': authHeader});
    }
    return null;
  }

  @override
  Future<Result<ApiResponse<Map<String, dynamic>>>> scanEventBarcode({
    required String qrData,
    CancelToken? cancelToken,
  }) async {
    print({"qrData": qrData});
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.scanEventBarcode,
      data: {"qrData": qrData},
      cancelToken: cancelToken,
      options: _tokenOptions,
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
    print({
      "eventId": eventId,
      "eventRegistrationId": eventRegistrationId,
      "memberId": memberId,
      "numberOfUsers": numberOfUsers,
    });
    return await _apiClient.postParsed<Map<String, dynamic>>(
      ApiEndpoints.checkInEventByQr,
      data: {
        "eventId": eventId,
        "eventRegistrationId": eventRegistrationId,
        "memberId": memberId,
        "numberOfUsers": numberOfUsers,
      },
      cancelToken: cancelToken,
      options: _tokenOptions,
      fromJsonT: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }
}
