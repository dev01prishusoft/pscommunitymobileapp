import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/registered_event_details_model.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class MyEventDetailsController extends GetxController {
  MyEventDetailsController({
    required EventsRepositories repository,
    required this.registrationId,
    this.initialItem,
  }) : _repository = repository;

  final EventsRepositories _repository;
  final String registrationId;
  final RegisteredEventItem? initialItem;

  final RxBool isLoading = false.obs;
  final RxBool isCancelling = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<RegisteredEventsDetailsData?> detail =
      Rx<RegisteredEventsDetailsData?>(null);

  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }

  Future<void> fetchDetail({bool isRefresh = false}) async {
    if (detail.value == null) {
      isLoading.value = true;
    }
    hasError.value = false;
    errorMessage.value = '';

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final result = await _repository.getMyRegisteredEventDetail(
      registrationId: registrationId,
      cancelToken: _cancelToken,
    );

    isLoading.value = false;

    if (result is Success<ApiResponse<RegisteredEventsDetailsData>>) {
      detail.value = result.data.data;
      // ignore: avoid_print
      print('getMyRegisteredEventDetail SUCCESS: ${result.data.data?.eventName}, guests count: ${result.data.data?.guests?.length}');
    } else if (result is Error<ApiResponse<RegisteredEventsDetailsData>>) {
      // ignore: avoid_print
      print('getMyRegisteredEventDetail ERROR: ${result.failure.message}');
      if (detail.value == null && initialItem == null) {
        hasError.value = true;
        errorMessage.value = result.failure.message;
      }
    }
  }

  Future<bool> cancelRegistration({String? reason}) async {
    final regId = detail.value?.eventRegistrationId ??
        initialItem?.eventRegistrationId ??
        int.tryParse(registrationId) ??
        0;
    final memId = detail.value?.memberId ?? initialItem?.memberId ?? 0;

    isCancelling.value = true;
    errorMessage.value = '';

    final result = await _repository.cancelRegistration(
      eventRegistrationId: regId,
      memberId: memId,
      cancellationReason: reason ?? LK.my_event_details_cancel_by_user.tr,
    );

    isCancelling.value = false;

    if (result is Success<ApiResponse<Map<String, dynamic>>>) {
      return true;
    } else if (result is Error<ApiResponse<Map<String, dynamic>>>) {
      errorMessage.value = result.failure.message;
      return false;
    }
    return false;
  }
}
