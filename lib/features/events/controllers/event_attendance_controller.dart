import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/event_attendance_repository.dart';

class EventAttendanceController extends GetxController {
  EventAttendanceController(this._repository);
  final EventAttendanceRepository _repository;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  final RxString currentQrData = ''.obs;
  final Rx<Map<String, dynamic>?> scannedData = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> checkInResponse = Rx<Map<String, dynamic>?>(
    null,
  );

  CancelToken? _cancelToken;

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }

  int _toInt(dynamic val, [int defaultValue = 0]) {
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? defaultValue;
  }

  Future<void> handleQrScan({required String qrData}) async {
    print("qrData :::: $qrData");
    currentQrData.value = qrData;
    isLoading.value = true;
    hasError.value = false;
    isSuccess.value = false;
    errorMessage.value = '';
    successMessage.value = '';
    scannedData.value = null;
    checkInResponse.value = null;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    // 1. Call scanEventBarcode API
    final scanResult = await _repository.scanEventBarcode(
      qrData: currentQrData.value,
      cancelToken: _cancelToken,
    );
    print(scanResult.dataOrNull);
    if (scanResult is Error<ApiResponse<Map<String, dynamic>>>) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = scanResult.failure.message.isNotEmpty
          ? scanResult.failure.message
          : 'Invalid QR Code or event attendance verification failed.';
      HapticFeedback.vibrate();
      return;
    }

    if (scanResult is Success<ApiResponse<Map<String, dynamic>>>) {
      final data = scanResult.data.data ?? <String, dynamic>{};
      scannedData.value = data;

      final int eventId = _toInt(data['eventId'] ?? data['EventId']);
      final int eventRegistrationId = _toInt(
        data['eventRegistrationId'] ?? data['EventRegistrationId'],
      );
      final int memberId = _toInt(data['memberId'] ?? data['MemberId']);
      final int numberOfUsers = _toInt(
        data['numberOfUsers'] ??
            data['NumberOfUsers'] ??
            data['numberOfGuests'] ??
            data['NumberOfGuests'] ??
            data['guestCount'] ??
            data['totalGuests'],
        1,
      );

      // 2. Call checkInEventByQr API with data from 1st API response
      final checkInResult = await _repository.checkInEventByQr(
        eventId: eventId,
        eventRegistrationId: eventRegistrationId,
        memberId: memberId,
        numberOfUsers: numberOfUsers,
        cancelToken: _cancelToken,
      );
print(checkInResult.dataOrNull);
      isLoading.value = false;

      if (checkInResult is Success<ApiResponse<Map<String, dynamic>>>) {
        isSuccess.value = true;
        successMessage.value =
            checkInResult.data.message ?? 'Attendee checked in successfully!';
        checkInResponse.value = checkInResult.data.data ?? <String, dynamic>{};
        HapticFeedback.heavyImpact();
      } else if (checkInResult is Error<ApiResponse<Map<String, dynamic>>>) {
        hasError.value = true;
        errorMessage.value = checkInResult.failure.message.isNotEmpty
            ? checkInResult.failure.message
            : 'Check-in failed.';
        HapticFeedback.vibrate();
      }
    }
  }

  void reset() {
    isLoading.value = false;
    hasError.value = false;
    isSuccess.value = false;
    errorMessage.value = '';
    successMessage.value = '';
    scannedData.value = null;
    checkInResponse.value = null;
    currentQrData.value = '';
  }
}
