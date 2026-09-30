import 'package:pscommunitymobileapp/core/config/env.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutParams {
  const RazorpayCheckoutParams({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.keyId,
    this.subscriptionId,
    this.description,
  });

  final String orderId;
  final int amountInPaise;
  final String currency;
  final String keyId;
  final String? subscriptionId;
  final String? description;
}

class RazorpayCheckoutService {
  RazorpayCheckoutService._();

  static bool open(
    Razorpay razorpay,
    RazorpayCheckoutParams params,
  ) {
    final key =
        params.keyId.trim().isNotEmpty ? params.keyId.trim() : Env.razorpayKey;
    if (key.isEmpty) {
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: LK.error.tr,
          subtitle: LK.paymentGatewayMissing.tr,
          isErrorMessage: true,
        ),
      ).show();
      return false;
    }

    if (params.amountInPaise <= 0) {
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: LK.error.tr,
          subtitle: LK.amountMustBeGreaterThanZero.tr,
          isErrorMessage: true,
        ),
      ).show();
      return false;
    }

    String samajName = '';
    String? samajLogoUrl;
    if (Get.isRegistered<SamajController>()) {
      final samaj = Get.find<SamajController>().samaj.value;
      samajName = samaj?.name ?? '';
      samajLogoUrl = samaj?.logoUrl;
    }
    if (samajName.trim().isEmpty) samajName = 'PS Community';

    final prefill = <String, String>{};
    if (Get.isRegistered<TokenManager>()) {
      final tm = Get.find<TokenManager>();
      final phone = tm.userPhone?.trim();
      final email = tm.userEmail?.trim();
      if (phone != null && phone.isNotEmpty) prefill['contact'] = phone;
      if (email != null && email.isNotEmpty) prefill['email'] = email;
    }

    final options = <String, dynamic>{
      'key': key,
      'amount': params.amountInPaise,
      'name': samajName,
      'description': params.description ?? LK.paymentForCommunity,
      'timeout': 300,
      if (samajLogoUrl != null && samajLogoUrl.isNotEmpty)
        'image': samajLogoUrl,
      if (prefill.isNotEmpty) 'prefill': prefill,
      'theme': {'color': '#1E3A8A'},
      'currency': params.currency,
    };

    final sub = params.subscriptionId;
    if (sub != null && sub.isNotEmpty) {
      options['subscription_id'] = sub;
    } else {
      options['order_id'] = params.orderId;
    }

    try {
      razorpay.open(options);
      return true;
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'RazorpayCheckoutService.open failed',
      );
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: LK.error.tr,
          subtitle: LK.paymentFailed.tr,
          isErrorMessage: true,
        ),
      ).show();
      return false;
    }
  }
}
