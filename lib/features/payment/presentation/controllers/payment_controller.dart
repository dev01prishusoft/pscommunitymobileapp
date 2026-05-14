import 'dart:async';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repository;

  PaymentController(this._repository);

  // --- Dashboard state ---
  final Rx<AppState> dashboardState = AppState.loading.obs;
  final Rxn<PaymentDashboard> dashboard = Rxn<PaymentDashboard>();
  
  // --- Make Payment form state ---
  final RxList<PaymentType> paymentTypes = <PaymentType>[].obs;
  final RxList<PaymentCategory> categories = <PaymentCategory>[].obs;
  final Rxn<PaymentType> selectedType = Rxn<PaymentType>();
  final Rxn<PaymentCategory> selectedCategory = Rxn<PaymentCategory>();
  final RxDouble enteredAmount = 0.0.obs;
  final RxBool isProcessingPayment = false.obs;
  
  // --- History state ---
  final Rx<AppState> historyState = AppState.loading.obs;
  final RxList<PaymentItem> payments = <PaymentItem>[].obs;
  final RxString selectedYear = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final Rxn<PaymentType> historyFilterType = Rxn<PaymentType>();
  
  // --- Razorpay ---
  late Razorpay _razorpay;
  int? _pendingAdminRequestId;
  
  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadDashboard();
    loadPaymentTypes();
  }
  
  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> loadDashboard() async {
    dashboardState.value = AppState.loading;
    try {
      final data = await _repository.getDashboard();
      dashboard.value = data;
      dashboardState.value = AppState.data;
    } catch (e) {
      dashboardState.value = AppState.error;
    }
  }

  Future<void> loadPaymentTypes() async {
    try {
      final types = await _repository.getPaymentTypes();
      paymentTypes.assignAll(types);
    } catch (e) {
      AppLogger.e('Failed to load payment types', e);
    }
  }

  Future<void> onTypeChanged(PaymentType? type) async {
    selectedType.value = type;
    selectedCategory.value = null;
    categories.clear();
    enteredAmount.value = 0.0;

    if (type != null) {
      try {
        final results = await _repository.getCategories(type.id);
        categories.assignAll(results);
      } catch (e) {
        AppLogger.e('Failed to load categories', e);
      }
    }
  }

  void onCategoryChanged(PaymentCategory? cat) {
    selectedCategory.value = cat;
    if (cat != null) {
      enteredAmount.value = cat.defaultAmount;
    }
  }

  Future<void> initiatePayment({int? adminPaymentRequestId, double? customAmount}) async {
    final amount = customAmount ?? enteredAmount.value;
    
    int? typeId;
    int? categoryId;

    if (adminPaymentRequestId != null) {
      final req = dashboard.value?.pendingPayments.firstWhere((p) => p.id == adminPaymentRequestId);
      typeId = req?.paymentTypeId;
      categoryId = req?.paymentCategoryId;
    } else {
      typeId = selectedType.value?.id;
      categoryId = selectedCategory.value?.id;
    }

    if (typeId == null || categoryId == null || amount < 100) {
      Get.snackbar(LK.error.tr, LK.selectValidPayment.tr);
      return;
    }

    isProcessingPayment.value = true;
    _pendingAdminRequestId = adminPaymentRequestId;

    try {
      final order = await _repository.createOrder(
        amount: amount,
        paymentTypeId: typeId,
        paymentCategoryId: categoryId,
        adminPaymentRequestId: adminPaymentRequestId,
      );

      const envKey = String.fromEnvironment('RAZORPAY_KEY');
      final key = envKey.isNotEmpty ? envKey : order.keyId;
      if (key.isEmpty) {
        Get.snackbar(LK.error.tr, LK.paymentGatewayMissing.tr);
        isProcessingPayment.value = false;
        return;
      }

      final options = {
        'key': key,
        'amount': order.amountInPaise,
        'name': LK.samajName.tr,
        'order_id': order.orderId,
        'description': LK.paymentForCommunity.tr,
        'timeout': 300, // in seconds
        'prefill': {
          'contact': '', // Add user contact if available
          'email': '',   // Add user email if available
        },
        'theme': {'color': '#1E3A8A'} // App primary color
      };

      _razorpay.open(options);
    } catch (e) {
      AppLogger.e('Failed to initiate payment', e);
      final errorMessage = e.toString();
      Get.snackbar(LK.error.tr, errorMessage.isNotEmpty ? errorMessage : LK.paymentFailed.tr);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.i('Payment Success: ${response.paymentId}');
    
    try {
      unawaited(Get.dialog<void>(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      ));
      
      final result = await _repository.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
        amount: enteredAmount.value,
        paymentTypeId: selectedType.value?.id ?? 0,
        paymentCategoryId: selectedCategory.value?.id ?? 0,
        adminPaymentRequestId: _pendingAdminRequestId,
      );
      
      Get.back<void>(); // Close loading
      
      final receiptId = result['receiptId'] as int?;
      
      await loadDashboard(); // Refresh
      
      if (receiptId != null) {
        unawaited(Get.toNamed<void>(AppRouter.paymentReceipt, arguments: {'receiptId': receiptId}));
      } else {
        Get.back<void>(); // Back from make payment
        Get.snackbar(LK.success.tr, LK.paymentSuccessful.tr);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back<void>(); // Close loading
      Get.snackbar(LK.error.tr, LK.verificationFailed.tr);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.e('Payment Error: ${response.code} - ${response.message}');
    Get.snackbar(LK.error.tr, response.message ?? LK.paymentFailed.tr);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.i('External Wallet: ${response.walletName}');
    Get.snackbar(LK.info.tr, LK.externalWalletSelected.tr);
  }

  Future<void> loadHistory({
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
  }) async {
    historyState.value = AppState.loading;
    try {
      final results = await _repository.getHistory(
        paymentTypeId: paymentTypeId,
        categoryId: categoryId,
        year: year,
        status: status,
      );
      payments.assignAll(results);
      historyState.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e) {
      historyState.value = AppState.error;
    }
  }

  Future<Map<String, dynamic>> getReceipt(int receiptId) async {
    try {
      return await _repository.getReceipt(receiptId);
    } catch (e) {
      AppLogger.e('Failed to load receipt', e);
      rethrow;
    }
  }
}
