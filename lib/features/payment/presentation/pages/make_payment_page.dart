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
    // Reset the form so previous selections are cleared when entering the screen
    controller.resetPaymentForm();
    
    amountController = TextEditingController();
    _amountListener = ever(controller.enteredAmount, (double val) {
      if (val > 0) {
        amountController.text = val.toStringAsFixed(0);
      } else {
        amountController.clear();
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
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.makePayment.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
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
            SizedBox(height: 24.h),
            _buildSectionHeader('PAYMENT MODE'),
            Obx(
              () => _buildDropdownField<PaymentMode>(
                hint: 'Select Payment Mode',
                value: controller.selectedMode.value,
                items: controller.paymentModes,
                onChanged: (mode) => controller.onModeChanged(mode),
                itemLabel: (mode) => mode.name,
              ),
            ),
            SizedBox(height: 24.h),
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
            SizedBox(height: 24.h),
            _buildSectionHeader(LK.amountHeader.tr),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        LK.amountLabel.tr,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '₹',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Obx(() {
                          final isFixed = controller.isAmountFixed;
                          return TextField(
                            controller: amountController,
                            readOnly: isFixed,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                if (newValue.text.isEmpty) return newValue;
                                final val = double.tryParse(newValue.text);
                                if (val == null) return oldValue;
                                final maxAmount = controller.selectedCategory.value?.maxAmount ?? 0;
                                if (maxAmount > 0 && val > maxAmount) {
                                  return oldValue;
                                }
                                return newValue;
                              }),
                            ],
                            onChanged: (val) => controller.enteredAmount.value =
                                double.tryParse(val) ?? 0,
                            style: AppTextStyles.displaySmall.copyWith(
                              color: isFixed ? AppColors.mutedForeground : AppColors.secondary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(),
                  SizedBox(height: 12.h),

                ],
              ),
            ),
            SizedBox(height: 40.h),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isProcessingPayment.value
                    ? null
                    : () => controller.initiatePayment(),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isProcessingPayment.value
                    ? CircularProgressIndicator(color: AppColors.white)
                    : Text(
                        LK.payNow.tr,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.white,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Divider(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.white : AppColors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.secondary),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), style: AppTextStyles.bodyMedium),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}
