import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/support_model.dart';

class SupportController extends GetxController {
  SupportController(this._apiClient);

  final ApiClient _apiClient;

  final RxBool isLoading = true.obs;
  final RxnString supportError = RxnString();

  final Rxn<SamajSupportTeam> supportData = Rxn<SamajSupportTeam>();

  bool _isFirstFetch = true;

  Future<void> fetchCustomerSupportDetail() async {
    if (isLoading.value && !_isFirstFetch) return;
    _isFirstFetch = false;

    isLoading.value = true;
    update();
    supportError.value = null;

    try {
      final response = await _apiClient.get(ApiEndpoints.customerSupport);

      final json = response.data as Map<String, dynamic>;
      supportData.value = SamajSupportTeam.fromJson(
        json['data'] as Map<String, dynamic>,
      );
      update();
    } catch (e) {
      supportError.value = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> openWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/${number.replaceAll('+', '')}');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);

    await launchUrl(uri);
  }

}
