import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';

class MakePaymentPage extends GetView<PaymentController> {
  const MakePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    
    // Listen to enteredAmount changes to update the text field
    ever(controller.enteredAmount, (double val) {
      if (val > 0) {
        amountController.text = val.toStringAsFixed(0);
      } else {
        amountController.clear();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.makePayment.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Payment Type Section
            _buildSectionHeader(LK.paymentTypeHeader.tr),
            Obx(() => _buildDropdownField<PaymentType>(
              hint: LK.selectPaymentType.tr,
              value: controller.selectedType.value,
              items: controller.paymentTypes,
              onChanged: (type) => controller.onTypeChanged(type),
              itemLabel: (type) => type.name,
            )),
            const SizedBox(height: 24),

            // Category Section
            _buildSectionHeader(LK.categoryHeader.tr),
            Obx(() => _buildDropdownField<PaymentCategory>(
              hint: LK.selectCategory.tr,
              value: controller.selectedCategory.value,
              items: controller.categories,
              onChanged: (cat) => controller.onCategoryChanged(cat),
              itemLabel: (cat) => cat.name,
              isEnabled: controller.selectedType.value != null,
            )),
            const SizedBox(height: 24),

            // Amount Section
            _buildSectionHeader(LK.amountHeader.tr),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => controller.enteredAmount.value = double.tryParse(val) ?? 0,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LK.minAmountLabel.tr,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        LK.maxAmountLabel.tr,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Pay Now Button
            Obx(() => ElevatedButton(
              onPressed: controller.isProcessingPayment.value 
                  ? null 
                  : () => controller.initiatePayment(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isProcessingPayment.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      LK.payNow.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.3))),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}
