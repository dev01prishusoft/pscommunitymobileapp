import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';

abstract class EventAttendanceRepository {
  void setCustomToken(String token);
  String get customToken;

  Future<Result<ApiResponse<Map<String, dynamic>>>> scanEventBarcode({
    required String qrData,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<Map<String, dynamic>>>> checkInEventByQr({
    required int eventId,
    required int eventRegistrationId,
    required int memberId,
    required int numberOfUsers,
    CancelToken? cancelToken,
  });
}
