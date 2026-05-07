import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';

class SamajController extends GetxController {
  final ApiClient _apiClient;

  SamajController(this._apiClient);

  final Rxn<Samaj> samaj = Rxn<Samaj>();
  final RxBool isLoading = false.obs;

  Future<void> fetchSamajDetail() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.samajDetail);
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] == true) {
        final data = json['data'] as Map<String, dynamic>;
        samaj.value = Samaj.fromJson(data);
        AppLogger.d('Samaj details loaded: ${samaj.value?.name}');
      }
    } catch (e, stack) {
      AppLogger.e('Failed to fetch samaj details', e, stack);
    } finally {
      isLoading.value = false;
    }
  }
}
