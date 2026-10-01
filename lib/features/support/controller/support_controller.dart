import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/safe_launcher.dart';

import '../../../core/models/support_model.dart';

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
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'SupportController.fetchCustomerSupportDetail failed',
      );
      supportError.value = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> openWhatsApp(String number) =>
      SafeLauncher.open('https://wa.me/${number.replaceAll('+', '')}');

  Future<bool> openEmail(String email) =>
      SafeLauncher.open('mailto:$email');

  Future<bool> launchSafeUrl(String s) => SafeLauncher.open(s);
}
