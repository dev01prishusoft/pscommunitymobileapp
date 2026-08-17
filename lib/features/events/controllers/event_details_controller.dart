import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';

class EventDetailsController extends GetxController {
  final int eventId;
  final EventsRepositories _repository;

  EventDetailsController(this.eventId, this._repository);

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<EventDetailsData?> eventDetails = Rx<EventDetailsData?>(null);

  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    fetchEventDetails();
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }

  Future<void> fetchEventDetails() async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    isLoading.value = true;
    hasError.value = false;

    final result = await _repository.getEventDetails(
      id: eventId,
      cancelToken: _cancelToken,
    );

    if (result is Success<ApiResponse<EventDetailsData>>) {
      final data = result.data.data;
      if (data != null) {
        _formatImageUrls(data);
        eventDetails.value = data;
      } else {
        hasError.value = true;
        errorMessage.value = "Details not found.";
      }
    } else if (result is Error) {
      hasError.value = true;
      errorMessage.value = "Failed to fetch event details.";
    }
    
    isLoading.value = false;
  }

  void _formatImageUrls(EventDetailsData data) {
    if (data.medias != null) {
      for (var media in data.medias!) {
        String? fullImageUrl = media.url;
        if (fullImageUrl != null &&
            fullImageUrl.isNotEmpty &&
            !fullImageUrl.startsWith('http')) {
          final baseUrl = AppEnvironment.I.apiBaseUrl.endsWith('/')
              ? AppEnvironment.I.apiBaseUrl.substring(
                  0,
                  AppEnvironment.I.apiBaseUrl.length - 1,
                )
              : AppEnvironment.I.apiBaseUrl;
          final imagePath = fullImageUrl.startsWith('/')
              ? fullImageUrl
              : '/$fullImageUrl';
          media.url = '$baseUrl$imagePath';
        }
      }
    }
  }
}
