import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/support_model.dart';

class SupportController extends GetxController {
  SupportController(this._apiClient);

  final ApiClient _apiClient;

  final RxBool isLoading = false.obs;
  final RxnString supportError = RxnString();

  final Rxn<SamajSupportTeam> supportData = Rxn<SamajSupportTeam>();

  Future<void> fetchCustomerSupportDetail() async {
    if (isLoading.value) return;

    isLoading.value = true;
    supportError.value = null;

    try {
      final response = await _apiClient.get(ApiEndpoints.customerSupport);

      final json = response.data as Map<String, dynamic>;
      supportData.value = SamajSupportTeam.fromJson(
        json['data'] as Map<String, dynamic>,
      );
      update();
    } catch (e, stack) {
      supportError.value = e.toString();
      AppLogger.e('Failed to fetch support details', e, stack);
    } finally {
      isLoading.value = false;
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

  Widget contactCard({
    required bool isWhatsApp,
    required String contactDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isWhatsApp
            ? AppColors.chart2.withValues(alpha: 0.3)
            : AppColors.chart5.withValues(alpha: 0.3),
      ),
      child: ListTile(
        leading: Icon(
          isWhatsApp ? Icons.chat : Icons.email,
          color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
        ),
        title: Text(
          contactDetails,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
          ),
        ),
        subtitle: Text(
          isWhatsApp ? 'WhatsApp Support' : 'Email Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
          ),
        ),
        onTap: () {
          if (contactDetails.isEmpty) return;
          if (isWhatsApp) {
            openWhatsApp(contactDetails);
          } else {
            openEmail(contactDetails);
          }
        },
      ),
    );
  }
}
