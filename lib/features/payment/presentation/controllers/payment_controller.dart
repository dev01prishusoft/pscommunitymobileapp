import 'dart:async';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_mode.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_dashboard.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class PaymentController extends GetxController {
  PaymentController(this._repository);
  final PaymentRepository _repository;
  final Rx<AppState> dashboardState = AppState.loading.obs;
  final Rxn<PaymentDashboard> dashboard = Rxn<PaymentDashboard>();
  final RxList<PaymentType> paymentTypes = <PaymentType>[].obs;
  final RxList<PaymentMode> paymentModes = <PaymentMode>[].obs;
  final RxList<PaymentCategory> categories = <PaymentCategory>[].obs;
  final Rxn<PaymentType> selectedType = Rxn<PaymentType>();
  final Rxn<PaymentMode> selectedMode = Rxn<PaymentMode>();
  final Rxn<PaymentCategory> selectedCategory = Rxn<PaymentCategory>();
  final RxDouble enteredAmount = 0.0.obs;

  bool get isAmountFixed {
    final cat = selectedCategory.value;
    if (cat != null && cat.defaultAmount > 0) return true;
    if (cat != null && cat.minAmount > 0 && cat.maxAmount > 0 && cat.minAmount == cat.maxAmount) return true;
    return false;
  }

  final RxBool isProcessingPayment = false.obs;
  final Rx<AppState> historyState = AppState.loading.obs;
  final RxList<PaymentItem> payments = <PaymentItem>[].obs;
  final RxString selectedYear = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final Rxn<PaymentType> historyFilterType = Rxn<PaymentType>();
  final RxList<PaymentCategory> historyCategories = <PaymentCategory>[].obs;
  final Rxn<PaymentCategory> historyFilterCategory = Rxn<PaymentCategory>();

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  final RxBool isLoadingMore = false.obs;
  late Razorpay _razorpay;
  int? _pendingAdminRequestId;
  bool _isCurrentPaymentRecurring = false;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    Future.wait([
      loadDashboard(),
      loadPaymentTypes(),
      loadPaymentModes(),
      loadHistory(),
    ]);
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

  Future<void> loadPaymentModes() async {
    try {
      final modes = await _repository.getPaymentModes();
      paymentModes.assignAll(modes);
    } catch (e) {
      AppLogger.e('Failed to load payment modes', e);
    }
  }

  void resetPaymentForm() {
    selectedType.value = null;
    selectedMode.value = null;
    selectedCategory.value = null;
    categories.clear();
    enteredAmount.value = 0.0;
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

  void onModeChanged(PaymentMode? mode) {
    selectedMode.value = mode;
  }

  void onCategoryChanged(PaymentCategory? cat) {
    selectedCategory.value = cat;
    if (cat != null) {
      enteredAmount.value = cat.defaultAmount;
    }
  }

  Future<void> initiatePayment({
    int? adminPaymentRequestId,
    double? customAmount,
    bool isRecurring = false,
  }) async {
    if (isProcessingPayment.value) return;

    final amount = customAmount ?? enteredAmount.value;

    int? typeId;
    int? categoryId;

    if (adminPaymentRequestId != null) {
      final req = dashboard.value?.pendingPayments.firstWhere(
        (p) => p.id == adminPaymentRequestId,
      );
      typeId = req?.paymentTypeId;
      categoryId = req?.paymentCategoryId;
    } else {
      typeId = selectedType.value?.id;
      categoryId = selectedCategory.value?.id;
    }

    if (adminPaymentRequestId == null) {
      if (typeId == null) {
        _showErrorSnackbar(LK.pleaseSelectPaymentType.tr);
        return;
      }
      if (selectedMode.value == null) {
        _showErrorSnackbar(LK.pleaseSelectPaymentMode.tr);
        return;
      }
      if (categoryId == null) {
        _showErrorSnackbar(LK.pleaseSelectCategory.tr);
        return;
      }
    } else {
      if (selectedMode.value == null) {
        _showErrorSnackbar(LK.pleaseSelectPaymentMode.tr);
        return;
      }
    }

    if (adminPaymentRequestId == null) {
      if ((selectedCategory.value?.minAmount ?? 0) > 0 && amount < selectedCategory.value!.minAmount) {
        _showErrorSnackbar('${LK.amountMustBeAtLeast.tr}${selectedCategory.value!.minAmount.toInt()}');
        return;
      }
      if ((selectedCategory.value?.maxAmount ?? 0) > 0 && amount > selectedCategory.value!.maxAmount) {
        _showErrorSnackbar('${LK.amountCannotExceed.tr}${selectedCategory.value!.maxAmount.toInt()}');
        return;
      }
      if (amount <= 0) {
        _showErrorSnackbar(LK.amountMustBeGreaterThanZero.tr);
        return;
      }
    } else {
      if (amount <= 0) {
        _showErrorSnackbar(LK.amountMustBeGreaterThanZero.tr);
        return;
      }
    }

    isProcessingPayment.value = true;
    _pendingAdminRequestId = adminPaymentRequestId;
    _isCurrentPaymentRecurring = isRecurring;

    try {
      final tokenManager = Get.find<TokenManager>();
      final memberId = tokenManager.memberId ?? 0;

      if (memberId == 0) {
        Get.snackbar(LK.error.tr, LK.couldNotDetermineMemberId.tr);
        return;
      }

      final int paymentModeId = selectedMode.value?.id ?? 0;
      final int paymentStatusId = 0;
      
      AppLogger.i('Initiating payment with: amount=$amount, typeId=$typeId, categoryId=$categoryId, memberId=$memberId');

      final order = await _repository.createOrder(
        amount: amount,
        paymentTypeId: typeId ?? 0,
        paymentCategoryId: categoryId ?? 0,
        adminPaymentRequestId: adminPaymentRequestId,
        memberId: memberId,
        paymentModeId: paymentModeId,
        paymentStatusId: paymentStatusId,
        description: LK.paymentForCommunity.tr,
        isRecurring: isRecurring,
      );

      const envKey = String.fromEnvironment('RAZORPAY_KEY');
      final key = envKey.isNotEmpty ? envKey : order.keyId;
      if (key.isEmpty) {
        Get.snackbar(LK.error.tr, LK.paymentGatewayMissing.tr);
        isProcessingPayment.value = false;
        return;
      }

      final String samajName = Get.isRegistered<SamajController>() 
          ? (Get.find<SamajController>().samaj.value?.name ?? LK.samajName.tr)
          : LK.samajName.tr;

      final String? samajLogoUrl = Get.isRegistered<SamajController>()
          ? Get.find<SamajController>().samaj.value?.logoUrl
          : null;

      final options = <String, dynamic>{
        'key': key,
        'amount': order.amountInPaise,
        'name': samajName,
        'description': LK.paymentForCommunity.tr,
        'timeout': 300,
        if (samajLogoUrl != null && samajLogoUrl.isNotEmpty) 'image': samajLogoUrl,
        'prefill': {
          'contact': (tokenManager.userPhone?.isNotEmpty ?? false) ? tokenManager.userPhone : '+919999999999', 
          'email': (tokenManager.userEmail?.isNotEmpty ?? false) ? tokenManager.userEmail : 'test@example.com'
        },
        'theme': {'color': '#1E3A8A'},
        'currency': 'INR',
      };

      if (isRecurring && order.subscriptionId != null && order.subscriptionId!.isNotEmpty) {
        options['subscription_id'] = order.subscriptionId!;
      } else {
        options['order_id'] = order.orderId;
      }

      _razorpay.open(options);
    } catch (e) {
      AppLogger.e('Failed to initiate payment', e);
      final errorMessage = e.toString();
      Get.snackbar(
        LK.error.tr,
        errorMessage.isNotEmpty ? errorMessage : LK.paymentFailed.tr,
      );
      isProcessingPayment.value = false;
      _pendingAdminRequestId = null;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.i('Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}, data=${response.data}');

    try {
      unawaited(
        Get.dialog<void>(
          Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        ),
      );

      final orderIdToUse = response.orderId ?? response.data?['razorpay_subscription_id']?.toString() ?? '';

      final result = await _repository.verifyPayment(
        razorpayOrderId: orderIdToUse,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        amount: enteredAmount.value,
        paymentTypeId: selectedType.value?.id ?? 0,
        paymentCategoryId: selectedCategory.value?.id ?? 0,
        adminPaymentRequestId: _pendingAdminRequestId,
        isRecurring: _isCurrentPaymentRecurring,
      );

      Get.back<void>();

      final receiptId = result['receiptId'] as int?;

      await loadDashboard();

      if (receiptId != null) {
        resetPaymentForm();
        unawaited(
          Get.toNamed<void>(
            AppRouter.paymentReceipt,
            arguments: {'receiptId': receiptId},
          ),
        );
      } else {
        Get.back<void>();
        resetPaymentForm();
        Get.snackbar(LK.success.tr, LK.paymentSuccessful.tr);
      }
    } catch (e, stack) {
      AppLogger.e('Payment Verification Exception', e, stack);
      if (Get.isDialogOpen ?? false) Get.back<void>();
      Get.snackbar(LK.error.tr, LK.verificationFailed.tr);
    } finally {
      isProcessingPayment.value = false;
      _pendingAdminRequestId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.e('Payment Error: ${response.code} - ${response.message}');
    
    String message = response.message ?? LK.paymentFailed.tr;
    bool shouldRedirectBack = false;
    
    if (message.toLowerCase().contains('timeout')) {
      message = LK.paymentTimedOut.tr;
      shouldRedirectBack = true;
    } else if (response.code == Razorpay.PAYMENT_CANCELLED || 
        message.toLowerCase().contains('undefined')) {
      message = LK.paymentCancelled.tr;
    }
    
    if (shouldRedirectBack) {
      Get.back<void>();
    }
    
    _showErrorSnackbar(message);
    isProcessingPayment.value = false;
    _pendingAdminRequestId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.i('External Wallet: ${response.walletName}');
    Get.snackbar(LK.info.tr, LK.externalWalletSelected.tr);
  }

  Future<void> onHistoryTypeChanged(PaymentType? type) async {
    historyFilterType.value = type;
    historyFilterCategory.value = null;
    historyCategories.clear();

    if (type != null) {
      try {
        final results = await _repository.getCategories(type.id);
        historyCategories.assignAll(results);
      } catch (e) {
        AppLogger.e('Failed to load history categories', e);
      }
    }
    
    await loadHistory(
      paymentTypeId: type?.id,
      year: int.tryParse(selectedYear.value),
      status: selectedStatus.value,
    );
  }

  Future<void> loadHistory({
    int? paymentTypeId,
    int? categoryId,
    int? year,
    String? status,
  }) async {
    _currentPage = 1;
    _hasMoreData = true;
    historyState.value = AppState.loading;
    try {
      final result = await _repository.getHistory(
        page: _currentPage,
        pageSize: _pageSize,
        paymentTypeId: paymentTypeId,
        categoryId: categoryId,
        year: year,
        status: status,
      );
      if (result.isFailure) {
        historyState.value = AppState.error;
      } else {
        final response = result.dataOrNull!;
        payments.assignAll(response.data);
        if (response.data.length < _pageSize) {
          _hasMoreData = false;
        }
        historyState.value = payments.isEmpty ? AppState.empty : AppState.data;
      }
    } catch (e) {
      historyState.value = AppState.error;
    }
  }

  Future<void> fetchMoreHistory() async {
    if (!_hasMoreData || isLoadingMore.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      final result = await _repository.getHistory(
        page: _currentPage,
        pageSize: _pageSize,
        paymentTypeId: historyFilterType.value?.id,
        year: int.tryParse(selectedYear.value),
        status: selectedStatus.value,
      );
      if (result.isFailure) {
        _currentPage--;
      } else {
        final response = result.dataOrNull!;
        payments.addAll(response.data);
        if (response.data.length < _pageSize) {
          _hasMoreData = false;
        }
      }
    } catch (e) {
      _currentPage--;
    }

    isLoadingMore.value = false;
  }

  Future<Map<String, dynamic>> getReceipt(int receiptId) async {
    try {
      return await _repository.getReceipt(receiptId);
    } catch (e) {
      AppLogger.e('Failed to load receipt', e);
      rethrow;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      LK.error.tr,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
