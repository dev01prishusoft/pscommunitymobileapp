import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_mode.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({super.key});

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final controller = Get.find<PaymentController>();
  late final TextEditingController amountController;
  late final Worker _amountListener;

  @override
  void initState() {
    super.initState();
    controller.resetPaymentForm();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.makePayment.tr)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
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
                    () => _buildDropdownField<PaymentType>(
                      hint: LK.selectPaymentType.tr,
                      value: controller.selectedType.value,
                      items: controller.paymentTypes,
                      onChanged: (type) => controller.onTypeChanged(type),
                      itemLabel: (type) => type.name,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionHeader(LK.paymentModeHeader.tr),
                  Obx(
                    () => _buildDropdownField<PaymentMode>(
                      hint: LK.selectPaymentMode.tr,
                      value: controller.selectedMode.value,
                      items: controller.paymentModes,
                      onChanged: (mode) => controller.onModeChanged(mode),
                      itemLabel: (mode) => mode.name,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionHeader(LK.categoryHeader.tr),
                  Obx(
                    () => _buildDropdownField<PaymentCategory>(
                      hint: LK.selectCategory.tr,
                      value: controller.selectedCategory.value,
                      items: controller.categories,
                      onChanged: (cat) => controller.onCategoryChanged(cat),
                      itemLabel: (cat) => cat.name,
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Obx(() {
                                final isFixed = controller.isAmountFixed;
                                return TextField(
                                  controller: amountController,
                                  readOnly: isFixed,
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
                                      if (newValue.text == '.') return newValue;
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
                                      if (maxAmount > 0 && val > maxAmount) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    }),
                                  ],
                                  onChanged: (val) =>
                                      controller.enteredAmount.value =
                                          double.tryParse(val) ?? 0,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    color: isFixed
                                        ? AppColors.grey.shade600
                                        : AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '0',
                                  ),
                                );
                              }),
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
                  Obx(() {
                    final cat = controller.selectedCategory.value;
                    if (cat != null && !controller.isAmountFixed) {
                      final min = cat.minAmount;
                      final max = cat.maxAmount;
                      if (min > 0 || max > 0) {
                        return Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (min > 0)
                                Text(
                                  '${LK.amountMustBeAtLeast.tr}${min.toInt()}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (max > 0)
                                Text(
                                  '${LK.amountCannotExceed.tr}${max.toInt()}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Obx(
              () => Column(
                children: [
                  GestureDetector(
                    onTap: controller.isProcessingPayment.value
                        ? null
                        : () => controller.initiatePayment(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: controller.isProcessingPayment.value
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : Text(
                              LK.payNow.tr,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  if (controller.selectedCategory.value?.isRecurring ==
                      true) ...[
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: controller.isProcessingPayment.value
                          ? null
                          : () => controller.initiatePayment(isRecurring: true),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.secondary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          LK.setupAutoPayRecurring.tr,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
                  color: isSelected ? AppColors.primary : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Text(
                  '₹$formatted',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.secondary,
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

  Widget _buildDropdownField<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemLabel,
    bool isEnabled = true,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.grey.shade50 : AppColors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.shade400,
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}
