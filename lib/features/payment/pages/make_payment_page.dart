import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/custom_dropdown_form_field.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/payment/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/core/models/payment_type.dart';
import 'package:pscommunitymobileapp/core/models/payment_category.dart';

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({super.key});

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final controller = Get.find<PaymentController>();
  late final TextEditingController amountController;
  late final Worker _amountListener;
  final _formKey = GlobalKey<FormState>();
  final _amountError = ValueNotifier<String>('');

  void _validateAmount(String? val) {
    if (val == null || val.isEmpty) {
      _amountError.value = LK.fieldRequired.tr;
      return;
    }
    final amt = double.tryParse(val);
    if (amt == null || amt <= 0) {
      _amountError.value = LK.amountMustBeGreaterThanZero.tr;
      return;
    }
    final cat = controller.selectedCategory.value;
    if (cat != null && !controller.isAmountFixed) {
      if (cat.minAmount > 0 && amt < cat.minAmount) {
        _amountError.value =
            '${LK.amountMustBeAtLeast.tr} ${cat.minAmount.toInt()}';
        return;
      }
      if (cat.maxAmount > 0 && amt > cat.maxAmount) {
        _amountError.value =
            '${LK.amountCannotExceed.tr} ${cat.maxAmount.toInt()}';
        return;
      }
    }
    _amountError.value = '';
  }

  @override
  void initState() {
    super.initState();
    controller.resetPaymentForm();
    if (controller.paymentModes.isEmpty) {
      controller.loadPaymentModes();
    }
    if (controller.paymentTypes.isEmpty) {
      controller.loadPaymentTypes();
    }

    amountController = TextEditingController();
    _amountListener = ever(controller.enteredAmount, (double val) {
      final currentVal = double.tryParse(amountController.text);
      if (currentVal != val) {
        if (val > 0) {
          if (val == val.toInt()) {
            amountController.text = val.toInt().toString();
          } else {
            amountController.text = val.toString();
          }
        } else {
          amountController.text = '';
        }
      }
    });
  }

  @override
  void dispose() {
    _amountListener.dispose();
    amountController.dispose();
    _amountError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text(LK.makePayment.tr)),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(LK.paymentTypeHeader.tr),
                      Obx(
                        () => CustomDropdownFormField<PaymentType>(
                          hint: LK.selectPaymentType.tr,
                          value: controller.selectedType.value,
                          items: controller.paymentTypes.map((type) {
                            return DropdownMenuItem<PaymentType>(
                              value: type,
                              child: Text(
                                type.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (type) => controller.onTypeChanged(type),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildSectionHeader(LK.categoryHeader.tr),
                      Obx(
                        () => CustomDropdownFormField<PaymentCategory>(
                          hint: LK.selectCategory.tr,
                          value: controller.selectedCategory.value,
                          items: controller.categories.map((cat) {
                            return DropdownMenuItem<PaymentCategory>(
                              value: cat,
                              child: Text(
                                cat.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (cat) {
                            controller.onCategoryChanged(cat);
                            _validateAmount(amountController.text);
                          },
                          isEnabled: controller.selectedType.value != null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(LK.amountHeader.tr),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  LK.amountLabel.tr,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  '₹',
                                  style: AppTextStyles.displaySmall.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  // Wrapping TextFormField inside Obx causes it to
                                  // be recreated on rebuild, detaching from FormState.
                                  // Use IgnorePointer+Obx to control readOnly safely.
                                  child: Obx(
                                    () => IgnorePointer(
                                      ignoring: controller.isAmountFixed,
                                      child: TextFormField(
                                        key: const ValueKey('amountField'),
                                        controller: amountController,
                                        cursorColor: AppColors.primary,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}'),
                                          ),
                                          LengthLimitingTextInputFormatter(8),
                                          TextInputFormatter.withFunction((
                                            oldValue,
                                            newValue,
                                          ) {
                                            if (newValue.text.isEmpty)
                                              return newValue;
                                            if (newValue.text == '.')
                                              return newValue;
                                            final val = double.tryParse(
                                              newValue.text,
                                            );
                                            if (val == null) return oldValue;
                                            final maxAmount =
                                                controller
                                                    .selectedCategory
                                                    .value
                                                    ?.maxAmount ??
                                                0;
                                            if (maxAmount > 0 &&
                                                val > maxAmount) {
                                              return oldValue;
                                            }
                                            return newValue;
                                          }),
                                        ],
                                        onChanged: (val) {
                                          controller.enteredAmount.value =
                                              double.tryParse(val) ?? 0;
                                          _validateAmount(val);
                                        },
                                        validator: (val) {
                                          if (val == null || val.isEmpty)
                                            return LK.fieldRequired.tr;
                                          final amt = double.tryParse(val);
                                          if (amt == null || amt <= 0)
                                            return LK
                                                .amountMustBeGreaterThanZero
                                                .tr;
                                          final cat =
                                              controller.selectedCategory.value;
                                          if (cat != null &&
                                              !controller.isAmountFixed) {
                                            if (cat.minAmount > 0 &&
                                                amt < cat.minAmount)
                                              return '${LK.amountMustBeAtLeast.tr} ${cat.minAmount.toInt()}';
                                            if (cat.maxAmount > 0 &&
                                                amt > cat.maxAmount)
                                              return '${LK.amountCannotExceed.tr} ${cat.maxAmount.toInt()}';
                                          }
                                          return null;
                                        },
                                        style: AppTextStyles.displaySmall
                                            .copyWith(
                                              color: controller.isAmountFixed
                                                  ? AppColors.grey.shade600
                                                  : AppColors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          filled: false,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0',
                                          hintStyle: AppTextStyles.displaySmall
                                              .copyWith(
                                                color: AppColors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          // Error shown below chips
                                          errorStyle: const TextStyle(
                                            height: 0,
                                            fontSize: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              final isFixed = controller.isAmountFixed;
                              if (isFixed) return const SizedBox.shrink();
                              return _buildQuickAmountChips();
                            }),
                          ],
                        ),
                      ),
                      // Reactive error shown below chips
                      ValueListenableBuilder<String>(
                        valueListenable: _amountError,
                        builder: (context, error, _) {
                          if (error.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 13,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    error,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.red.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() {
                  if (controller.selectedCategory.value?.isRecurring != true) {
                    return const SizedBox.shrink();
                  }
                  final isRecurringLoading =
                      controller.isProcessingRecurring.value;
                  final isAnyLoading =
                      controller.isProcessingPayment.value ||
                      isRecurringLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: isAnyLoading
                            ? null
                            : () {
                                _validateAmount(amountController.text);
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  controller.initiatePayment(isRecurring: true);
                                }
                              },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.secondary),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isRecurringLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : Text(
                                  LK.setupAutoPayRecurring.tr,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ).paddingSymmetric(horizontal: 10.w),
                      SizedBox(height: 20.h),
                    ],
                  );
                }),
                Obx(
                  () => AppPrimaryButton(
                    height: 50.h,
                    isLoading: controller.isProcessingPayment.value,
                    text: LK.payNow.tr,
                    onPressed:
                        (controller.isProcessingPayment.value ||
                            controller.isProcessingRecurring.value)
                        ? null
                        : () {
                            _validateAmount(amountController.text);
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.initiatePayment();
                            }
                          },
                  ).paddingSymmetric(horizontal: 10.w),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChips() {
    final cat = controller.selectedCategory.value;
    final min = cat?.minAmount ?? 0.0;
    final max = cat?.maxAmount ?? 0.0;

    final amounts = [500.0, 1000.0, 2000.0, 5000.0];
    final filteredAmounts = amounts.where((amt) {
      if (min > 0 && amt < min) return false;
      if (max > 0 && amt > max) return false;
      return true;
    }).toList();

    if (filteredAmounts.isEmpty && min > 0) {
      filteredAmounts.add(min);
    }

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: filteredAmounts.map((amt) {
          final formatted = amt == amt.toInt()
              ? amt.toInt().toString()
              : amt.toString();
          return InkWell(
            onTap: () {
              amountController.text = formatted;
              controller.enteredAmount.value = amt;
            },
            borderRadius: BorderRadius.circular(20),
            child: Obx(() {
              final isSelected = controller.enteredAmount.value == amt;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Text(
                  '₹$formatted',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, left: 6),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
