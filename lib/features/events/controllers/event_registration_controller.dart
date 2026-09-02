import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/coupon_apply_model.dart';
import 'package:pscommunitymobileapp/core/models/event_create_order_model.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/core/models/event_validate_model.dart';
import 'package:pscommunitymobileapp/core/models/gender_model.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_details_controller.dart';
import 'package:pscommunitymobileapp/features/events/controllers/events_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CustomGuestForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final Rx<GenderData?> selectedGender = Rx<GenderData?>(null);
  final Rx<int?> selectedGenderID = Rx<int?>(null);
  final RxString gender = ''.obs;

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    mobileController.dispose();
  }
}

class EventRegistrationController extends GetxController {
  final EventsRepositories _repository;
  EventRegistrationController({required EventsRepositories repository})
    : _repository = repository;

  final formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final Rx<Member?> currentUser = Rx<Member?>(null);

  final RxList<Member> familyMembers = <Member>[].obs;
  final RxBool isLoadingMembers = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString memberSearchQuery = ''.obs;

  final RxList<int> selectedMemberIds = <int>[].obs;

  final RxList<CustomGuestForm> customGuests = <CustomGuestForm>[].obs;
  final TextEditingController couponController = TextEditingController();

  final ExpansibleController membersTileController = ExpansibleController();
  final ExpansibleController guestsTileController = ExpansibleController();

  final RxBool isLoadingCoupon = false.obs;
  final Rx<CouponApplyData?> appliedCoupon = Rx<CouponApplyData?>(null);
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isValidating = false.obs;
  final Rx<EventValidateData?> validationData = Rx<EventValidateData?>(null);
  final Rx<CreateOrderData?> orderData = Rx<CreateOrderData?>(null);
  final RxBool isProcessingPayment = false.obs;
  late Razorpay _razorpay;

  List<Map<String, dynamic>> _registeredGuests = [];
  EventDetailsData? _registeredEvent;
  int _currentEventId = 0;

  CancelToken? _cancelToken;

  final List<GenderData> defaultGenders = [
    GenderData(genderId: 1, name: 'Male'),
    GenderData(genderId: 2, name: 'Female'),
    GenderData(genderId: 3, name: 'Other'),
  ];
  final Rx<GenderData?> gender = Rx<GenderData?>(null);
  final RxList<GenderData> genderList = <GenderData>[].obs;

  void _showToast(String title, String? subtitle, {bool isError = false}) {
    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) =>
          ToastCard(title: title, subtitle: subtitle, isErrorMessage: isError),
    ).show();
  }

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    genderList.assignAll(defaultGenders);
    _loadCurrentUser();
    _fetchFamilyMembers();
    fetchGenderDropdown();
  }

  Future<void> fetchGenderDropdown() async {
    try {
      final result = await _repository.getGenderDropdown(
        cancelToken: _cancelToken,
      );
      if (result is Success<ApiResponse<List<GenderData>>>) {
        final list = result.data.data;
        if (list != null && list.isNotEmpty) {
          genderList.assignAll(list);
        }
      }
    } catch (_) {}
  }

  List<Member> get filteredFamilyMembers {
    if (memberSearchQuery.value.isEmpty) {
      return familyMembers;
    }
    final query = memberSearchQuery.value.toLowerCase();
    return familyMembers
        .where((m) => m.fullName.toLowerCase().contains(query))
        .toList();
  }

  void onSearchChanged(String query) {
    memberSearchQuery.value = query;
  }

  void _loadCurrentUser() {
    if (Get.isRegistered<DrawerUserController>()) {
      currentUser.value = Get.find<DrawerUserController>().member.value;
    }
  }

  Future<void> _fetchFamilyMembers() async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        '/api/v1/member/mobile/list',
        queryParameters: {
          'Page': 1,
          'PageSize': 100, // Fetch all reasonable members
        },
      );

      if (response.data['succeeded'] == true) {
        final dataObj = response.data['data'];
        if (dataObj is Map<String, dynamic>) {
          final listData = dataObj['data'] as List<dynamic>? ?? [];
          final allMembers = listData
              .map((e) => Member.fromJson(e as Map<String, dynamic>))
              .toList();

          // Filter for approved members
          var approvedMembers = allMembers
              .where((m) => m.approveStatus?.toLowerCase() == 'approved')
              .toList();

          // Add the current user to the list if not already present
          if (currentUser.value != null) {
            final currentUserId = currentUser.value!.memberId;
            if (!approvedMembers.any((m) => m.memberId == currentUserId)) {
              approvedMembers.insert(0, currentUser.value!);
            }
          }

          familyMembers.value = approvedMembers;
        }
      }
    } catch (_) {
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void toggleMemberSelection(int memberId) {
    if (selectedMemberIds.contains(memberId)) {
      selectedMemberIds.remove(memberId);
    } else {
      selectedMemberIds.add(memberId);
    }
  }

  void addCustomGuest({required EventDetailsData event}) {
    if (customGuests.length < (event.maximumGuestsPerMember ?? 0)) {
      customGuests.add(CustomGuestForm());
    } else {
      _showToast(
        LK.error.tr,
        'You cannot add more custom guests for this event.',
        isError: true,
      );
    }
  }

  void removeCustomGuest(int index) {
    if (index >= 0 && index < customGuests.length) {
      customGuests[index].dispose();
      customGuests.removeAt(index);
    }
  }

  Future<void> _applyCoupon({required EventDetailsData event}) async {
    final coupon = couponController.text.trim();
    if (coupon.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Please enter a coupon code.';
      return;
    }

    if (event.eventId == null) {
      hasError.value = true;
      errorMessage.value = 'Invalid event details. Event ID is missing.';
      return;
    }

    if (currentUser.value?.memberId == null) {
      hasError.value = true;
      errorMessage.value = 'Member details not found. Please log in again.';
      return;
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    isLoadingCoupon.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.applyCoupon(
        eventId: event.eventId!,
        memberId: currentUser.value!.memberId,
        couponCode: coupon,
        guestCount: customGuests.length,
        cancelToken: _cancelToken,
      );

      if (result is Success<ApiResponse<CouponApplyData>>) {
        final couponData = result.data.data;
        if (couponData != null) {
          appliedCoupon.value = couponData;
          hasError.value = false;
          errorMessage.value = '';
        } else {
          appliedCoupon.value = null;
          hasError.value = true;
          errorMessage.value = result.data.message ?? "Failed to apply coupon.";
        }
      } else if (result is Error<ApiResponse<CouponApplyData>>) {
        appliedCoupon.value = null;
        hasError.value = true;
        errorMessage.value = result.failure.message.isNotEmpty
            ? result.failure.message
            : "Failed to apply coupon.";
      }
    } catch (e) {
      appliedCoupon.value = null;
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoadingCoupon.value = false;
    }
  }

  Future<void> registerNow({required EventDetailsData event}) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedMemberIds.isEmpty && customGuests.isEmpty) {
      _showToast(
        LK.error.tr,
        'Please select at least one member or add a guest.',
        isError: true,
      );
      return;
    }

    // Validate that custom guests have a selected gender
    for (int i = 0; i < customGuests.length; i++) {
      final g = customGuests[i];
      if ((g.selectedGenderID.value ?? 0) <= 0) {
        _showToast(
          LK.error.tr,
          'Please select gender for Guest ${i + 1}.',
          isError: true,
        );
        return;
      }
    }

    final currentUserId = currentUser.value?.memberId;

    // Build guests list cleanly: exclude logged-in user and no null memberId
    final guests = [
      ...familyMembers
          .where(
            (m) =>
                selectedMemberIds.contains(m.memberId) &&
                m.memberId != currentUserId,
          )
          .map(
            (m) => {
              "memberId": m.memberId,
              "guestName": m.fullName,
              "mobileNo": m.mobileNo ?? '',
              "age": m.age,
              "genderId": m.genderId ?? 0,
            },
          ),
      ...customGuests.map(
        (g) => {
          "guestName": g.nameController.text.trim(),
          "mobileNo": g.mobileController.text.trim(),
          "age": int.tryParse(g.ageController.text.trim()) ?? 0,
          "genderId": g.selectedGenderID.value ?? 0,
        },
      ),
    ];

    _registeredGuests = guests;
    _registeredEvent = event;

    final eventId = event.eventId;
    final memberId = currentUser.value?.memberId;
    if (eventId == null || memberId == null) {
      _showToast(
        LK.error.tr,
        'Missing event or member details.',
        isError: true,
      );
      return;
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    isValidating.value = true;

    try {
      final result = await _repository.eventValidator(
        eventId: eventId,
        memberId: memberId,
        guests: guests,
        cancelToken: _cancelToken,
      );

      if (result is Success<ApiResponse<EventValidateData>>) {
        final data = result.data.data;
        validationData.value = data;

        if (data?.isNeedToPay == false || (data?.originalAmount ?? 0) <= 0) {
          _handleFreeRegistration(event: event);
          return;
        }

        _showCouponBottomSheet(guests, event: event);
      } else if (result is Error<ApiResponse<EventValidateData>>) {
        _showToast(
          LK.error.tr,
          result.failure.message.isNotEmpty
              ? result.failure.message
              : 'Failed to validate registration.',
          isError: true,
        );
      }
    } catch (e) {
      _showToast(
        LK.error.tr,
        'Something went wrong while validating registration.',
        isError: true,
      );
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> eventCreateorder({required EventDetailsData event}) async {
    Get.dialog(
      Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      final result = await _repository.eventCreateorder(
        eventId: event.eventId!,
        memberId: currentUser.value!.memberId,
        eventCouponId: appliedCoupon.value?.eventCouponId ?? 0,
        guestCount: customGuests.length,
        cancelToken: _cancelToken,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (result is Success<ApiResponse<CreateOrderData>>) {
        final data = result.data.data;
        orderData.value = data;

        if (data != null && data.orderId != null && data.orderId!.isNotEmpty) {
          _openRazorpayCheckout(data, event: event);
        } else {
          _showToast(
            LK.error.tr,
            'Invalid order response from server.',
            isError: true,
          );
        }
      } else if (result is Error<ApiResponse<CreateOrderData>>) {
        _showToast(
          LK.error.tr,
          result.failure.message.isNotEmpty
              ? result.failure.message
              : 'Failed to create payment order.',
          isError: true,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showToast(
        LK.error.tr,
        'Something went wrong while creating order.',
        isError: true,
      );
    }
  }

  void _openRazorpayCheckout(
    CreateOrderData order, {
    required EventDetailsData event,
  }) {
    isProcessingPayment.value = true;
    try {
      final tokenManager = Get.find<TokenManager>();
      const envKey = String.fromEnvironment('RAZORPAY_KEY');
      final key = envKey.isNotEmpty ? envKey : (order.keyId ?? '');
      if (key.isEmpty) {
        PSDelightToastBar(
          snackbarDuration: const Duration(seconds: 3),
          builder: (context) => ToastCard(
            title: LK.error.tr,
            subtitle: LK.paymentGatewayMissing.tr,
            isErrorMessage: true,
          ),
        ).show();
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
        'description': event.eventName ?? LK.paymentForCommunity.tr,
        'timeout': 300,
        if (samajLogoUrl != null && samajLogoUrl.isNotEmpty)
          'image': samajLogoUrl,
        'prefill': {
          'contact': (tokenManager.userPhone?.isNotEmpty ?? false)
              ? tokenManager.userPhone
              : '+919999999999',
          'email': (tokenManager.userEmail?.isNotEmpty ?? false)
              ? tokenManager.userEmail
              : 'test@example.com',
        },
        'theme': {'color': '#1E3A8A'},
        'currency': order.currency ?? 'INR',
        'order_id': order.orderId,
      };

      _currentEventId = event.eventId ?? 0;
      _registeredEvent = event;
      _razorpay.clear();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      _razorpay.open(options);
    } catch (e) {
      final errorMessage = e.toString();
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: LK.error.tr,
          subtitle: errorMessage.isNotEmpty
              ? errorMessage
              : LK.paymentFailed.tr,
          isErrorMessage: true,
        ),
      ).show();
      isProcessingPayment.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isProcessingPayment.value = false;
    Get.dialog(
      Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      final orderIdToUse =
          response.orderId ??
          orderData.value?.orderId ??
          response.data?['razorpay_order_id']?.toString() ??
          '';
      final eventId = _currentEventId != 0
          ? _currentEventId
          : (_registeredEvent?.eventId ?? 0);
      final memberId = currentUser.value?.memberId ?? 0;
      final eventCouponId = appliedCoupon.value?.eventCouponId;

      List<Map<String, dynamic>> guestsToUse = _registeredGuests;
      if (guestsToUse.isEmpty) {
        final currentUserId = currentUser.value?.memberId;
        guestsToUse = [
          ...familyMembers
              .where(
                (m) =>
                    selectedMemberIds.contains(m.memberId) &&
                    m.memberId != currentUserId,
              )
              .map(
                (m) => {
                  "memberId": m.memberId,
                  "guestName": m.fullName,
                  "mobileNo": m.mobileNo ?? '',
                  "age": m.age,
                  "genderId": m.genderId ?? 0,
                },
              ),
          ...customGuests.map(
            (g) => {
              "memberId": 0,
              "guestName": g.nameController.text.trim(),
              "mobileNo": g.mobileController.text.trim(),
              "age": int.tryParse(g.ageController.text.trim()) ?? 0,
              "genderId": g.selectedGenderID.value ?? 0,
            },
          ),
        ];
      }

      final verifyGuests = guestsToUse
          .map(
            (g) => {
              "memberId": g["memberId"] ?? null,
              "guestName": g["guestName"] ?? "",
              "mobileNo": g["mobileNo"] ?? "",
              "age": g["age"] ?? 0,
              "genderId": g["genderId"] ?? 0,
            },
          )
          .toList();

      final result = await _repository.eventVerifyPayment(
        razorpayOrderId: orderIdToUse,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        eventId: eventId,
        memberId: memberId,
        eventCouponId: eventCouponId,
        notes: "",
        guests: verifyGuests,
        cancelToken: _cancelToken,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (result is Success<ApiResponse<Map<String, dynamic>>>) {
        if (Get.isBottomSheetOpen ?? false) Get.back();
        _showToast(
          LK.success.tr,
          result.data.message ?? LK.paymentSuccessful.tr,
        );
        navigateBackAfterRegister();
      } else if (result is Error<ApiResponse<Map<String, dynamic>>>) {
        _showToast(
          LK.error.tr,
          result.failure.message.isNotEmpty
              ? result.failure.message
              : LK.verificationFailed.tr,
          isError: true,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showToast(LK.error.tr, LK.verificationFailed.tr, isError: true);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessingPayment.value = false;
    String message = response.message ?? LK.paymentFailed.tr;
    if (message.toLowerCase().contains('timeout')) {
      message = LK.paymentTimedOut.tr;
    } else if (response.code == Razorpay.PAYMENT_CANCELLED ||
        message.toLowerCase().contains('undefined')) {
      message = LK.paymentCancelled.tr;
    }
    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) => ToastCard(
        title: LK.error.tr,
        subtitle: message,
        isErrorMessage: true,
      ),
    ).show();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) =>
          ToastCard(title: LK.info.tr, subtitle: LK.externalWalletSelected.tr),
    ).show();
  }

  void _showCouponBottomSheet(
    List<Map<String, dynamic>> registrationList, {
    required EventDetailsData event,
  }) {
    // Reset error states when opening bottomsheet
    hasError.value = false;
    errorMessage.value = '';
    appliedCoupon.value = null;
    couponController.clear();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 16.h,
          bottom: 20.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Header with Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration Summary',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey.shade900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Review details before making payment',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.grey.shade600,
                      size: 20.sp,
                    ),
                    splashRadius: 20.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Modern Price Breakdown Card
              Obx(() {
                final coupon = appliedCoupon.value;
                final num origAmount =
                    validationData.value?.originalAmount ??
                    event.registrationFee ??
                    0;
                final bool hasCoupon =
                    coupon != null && (coupon.discountAmount ?? 0) > 0;
                final num finalAmount = coupon?.finalAmount ?? origAmount;

                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Original Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Iconsax.receipt_2,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Registration Fee',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Base amount',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey.shade500,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₹$origAmount',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: hasCoupon
                                  ? AppColors.grey.shade400
                                  : AppColors.grey.shade900,
                              decoration: hasCoupon
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      // Coupon Discount Row (if applied)
                      if (hasCoupon) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Divider(
                            color: AppColors.grey.shade200,
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Iconsax.ticket_discount,
                                    size: 18.sp,
                                    color: AppColors.green,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Coupon Discount',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.green,
                                      ),
                                    ),
                                    Text(
                                      couponController.text.trim().isNotEmpty
                                          ? couponController.text
                                                .trim()
                                                .toUpperCase()
                                          : 'Discount applied',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.green,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '- ₹${coupon.discountAmount}',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ],

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Divider(
                          color: AppColors.grey.shade200,
                          height: 1,
                        ),
                      ),

                      // Final Payable Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Payable',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey.shade900,
                                ),
                              ),
                              Text(
                                'Final amount to pay',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey.shade500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹$finalAmount',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 20.h),

              // Coupon Header
              Text(
                'Apply Coupon',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey.shade800,
                ),
              ),
              SizedBox(height: 10.h),

              Obx(
                () => AppTextField(
                  controller: couponController,
                  hint: 'Enter coupon code',
                  icon: Iconsax.ticket_discount,
                  readOnly: appliedCoupon.value != null,
                  onChanged: (_) {
                    if (appliedCoupon.value != null) {
                      appliedCoupon.value = null;
                    }
                    if (hasError.value) {
                      hasError.value = false;
                      errorMessage.value = '';
                    }
                  },
                  suffixIcon: isLoadingCoupon.value
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : appliedCoupon.value != null
                      ? TextButton(
                          onPressed: () {
                            appliedCoupon.value = null;
                            couponController.clear();
                            hasError.value = false;
                            errorMessage.value = '';
                          },
                          child: Text(
                            'Remove',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () => _applyCoupon(event: event),
                          child: Text(
                            'Apply',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),

              // Error Message below Coupon TextField
              Obx(
                () => hasError.value && errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 14.sp,
                              color: AppColors.red,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                errorMessage.value,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Success Banner when Coupon Applied
              Obx(
                () => appliedCoupon.value != null
                    ? Container(
                        margin: EdgeInsets.only(top: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.green,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Coupon applied! You save ₹${appliedCoupon.value?.discountAmount ?? 0}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              // Pay Now Button
              Obx(() {
                final coupon = appliedCoupon.value;
                final num origAmount =
                    validationData.value?.originalAmount ??
                    event.registrationFee ??
                    0;
                final num finalAmount = coupon?.finalAmount ?? origAmount;
                final String buttonText = 'Pay Now · ₹$finalAmount';

                return AppPrimaryButton(
                  onPressed: () {
                    Get.back();
                    _onPayNow(registrationList, event: event);
                  },
                  text: buttonText,
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _onPayNow(
    List<Map<String, dynamic>> registrationList, {
    required EventDetailsData event,
  }) {
    final num? amountToPay =
        appliedCoupon.value?.finalAmount ??
        validationData.value?.originalAmount ??
        event.registrationFee;
    final bool isNeedToPay =
        appliedCoupon.value?.isNeedToPay ??
        validationData.value?.isNeedToPay ??
        (amountToPay != null && amountToPay > 0);

    if (isNeedToPay && amountToPay != null && amountToPay > 0) {
      eventCreateorder(event: event);
    } else {
      _handleFreeRegistration(event: event);
    }
  }

  Future<void> _handleFreeRegistration({
    required EventDetailsData event,
  }) async {
    Get.dialog(
      Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      final eventId = _currentEventId != 0
          ? _currentEventId
          : (event.eventId ?? _registeredEvent?.eventId ?? 0);
      final memberId = currentUser.value?.memberId ?? 0;

      List<Map<String, dynamic>> guestsToUse = _registeredGuests;
      if (guestsToUse.isEmpty) {
        final currentUserId = currentUser.value?.memberId;
        guestsToUse = [
          ...familyMembers
              .where(
                (m) =>
                    selectedMemberIds.contains(m.memberId) &&
                    m.memberId != currentUserId,
              )
              .map(
                (m) => {
                  "memberId": m.memberId,
                  "guestName": m.fullName,
                  "mobileNo": m.mobileNo ?? '',
                  "age": m.age,
                  "genderId": m.genderId ?? 0,
                },
              ),
          ...customGuests.map(
            (g) => {
              "memberId": 0,
              "guestName": g.nameController.text.trim(),
              "mobileNo": g.mobileController.text.trim(),
              "age": int.tryParse(g.ageController.text.trim()) ?? 0,
              "genderId": g.selectedGenderID.value ?? 0,
            },
          ),
        ];
      }

      final formattedGuests = guestsToUse
          .map(
            (g) => {
              "memberId": g["memberId"] ?? null,
              "guestName": g["guestName"] ?? "",
              "mobileNo": g["mobileNo"] ?? "",
              "age": g["age"] ?? 0,
              "genderId": g["genderId"] ?? 0,
            },
          )
          .toList();

      final result = await _repository.eventFreeRegister(
        eventId: eventId,
        memberId: memberId,
        notes: "",
        guests: formattedGuests,
        cancelToken: _cancelToken,
      );
      print("result.failureOrNull?.message : ${result.failureOrNull?.message}");
      if (Get.isDialogOpen ?? false) Get.back();

      if (result is Success<ApiResponse<Map<String, dynamic>>>) {
        if (Get.isBottomSheetOpen ?? false) Get.back();
        _showToast(
          LK.success.tr,
          result.data.message ?? 'Registration successful!',
        );
        navigateBackAfterRegister();
      } else if (result is Error<ApiResponse<Map<String, dynamic>>>) {
        _showToast(
          LK.error.tr,
          result.failure.message.isNotEmpty
              ? result.failure.message
              : 'Registration failed.',
          isError: true,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showToast(
        LK.error.tr,
        'Something went wrong while registering.',
        isError: true,
      );
    }
  }

  void navigateBackAfterRegister() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.back(); // close registration page
    if (Get.isRegistered<EventDetailsController>()) {
      Get.find<EventDetailsController>().fetchEventDetails(isSilent: true);
    }
    if (Get.isRegistered<EventsController>()) {
      Get.find<EventsController>().refreshEventsSilently();
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    searchController.dispose();
    couponController.dispose();
    for (var form in customGuests) {
      form.dispose();
    }
    if (Get.isRegistered<EventDetailsController>()) {
      Get.find<EventDetailsController>().fetchEventDetails(isSilent: true);
    }
    if (Get.isRegistered<EventsController>()) {
      Get.find<EventsController>().refreshEventsSilently();
    }
    super.onClose();
  }
}
