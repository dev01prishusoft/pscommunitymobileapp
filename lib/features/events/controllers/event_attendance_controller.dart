import 'package:dio/dio.dart';
import 'package:get/get.dart';
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

  void setCustomToken(String token) {
    _repository.setCustomToken(token);
  }

  String get customToken => _repository.customToken;

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
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
