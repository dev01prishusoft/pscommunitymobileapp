import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class PaymentHistoryPage extends GetView<PaymentController> {
  const PaymentHistoryPage({super.key});

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
          LK.paymentHistory.tr,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.secondary,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildFilterDropdown(
                          label: '${LK.paymentTypeLabel.tr}:',
                          hint: LK.allTypes.tr,
                          value: controller.historyFilterType.value?.name,
                          items: controller.paymentTypes
                              .map((t) => t.name)
                              .toList(),
                          onChanged: (val) {
                            if (val == null) {
                              controller.onHistoryTypeChanged(null);
                            } else {
                              controller.onHistoryTypeChanged(controller
                                  .paymentTypes
                                  .firstWhere((t) => t.name == val));
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => _buildFilterDropdown(
                          label: '${LK.categoryLabel.tr}:',
                          hint: LK.allCategories.tr,
                          value: controller.historyFilterCategory.value?.name,
                          items: controller.historyCategories
                              .map((c) => c.name)
                              .toList(),
                          onChanged: (val) {
                            if (val == null) {
                              controller.historyFilterCategory.value = null;
                            } else {
                              controller.historyFilterCategory.value = controller
                                  .historyCategories
                                  .firstWhere((c) => c.name == val);
                            }
                            controller.loadHistory(
                              paymentTypeId: controller.historyFilterType.value?.id,
                              categoryId: controller.historyFilterCategory.value?.id,
                              year: int.tryParse(controller.selectedYear.value),
                              status: controller.selectedStatus.value,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildFilterDropdown(
                          label: '${LK.yearLabel.tr}:',
                          hint: '2025',
                          value: controller.selectedYear.value.isEmpty
                              ? null
                              : controller.selectedYear.value,
                          items: ['2025', '2024', '2023'],
                          onChanged: (val) {
                            controller.selectedYear.value = val ?? '';
                            controller.loadHistory(
                              paymentTypeId: controller.historyFilterType.value?.id,
                              categoryId: controller.historyFilterCategory.value?.id,
                              year: int.tryParse(val ?? ''),
                              status: controller.selectedStatus.value,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => _buildFilterDropdown(
                          label: '${LK.statusLabel.tr}:',
                          hint: LK.all.tr,
                          value: controller.selectedStatus.value,
                          items: ['All', 'Success', 'Pending', 'Failed'],
                          onChanged: (val) {
                            controller.selectedStatus.value = val ?? 'All';
                            controller.loadHistory(
                              paymentTypeId: controller.historyFilterType.value?.id,
                              categoryId: controller.historyFilterCategory.value?.id,
                              year: int.tryParse(controller.selectedYear.value),
                              status: val,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => AppStateView(
                state: controller.historyState.value,
                onRetry: () => controller.loadHistory(),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.payments.length,
                  itemBuilder: (context, index) {
                    final payment = controller.payments[index];
                    return _PaymentCard(payment: payment);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed<void>(AppRouter.makePayment),
        backgroundColor: AppColors.info,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    String? value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Container(
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(
                  hint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.black87,
                  ),
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black87,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.black54,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(hint)),
                  ...items.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s)),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentItem payment;

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(payment.title);
    final iconData = _getIconData(payment.title);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${payment.amount}  |  ${payment.date}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${payment.type}  |  ${payment.method}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    Text(
                      payment.status.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: payment.status == PaymentStatus.success
                            ? AppColors.success
                            : payment.status == PaymentStatus.failed
                                ? AppColors.destructive
                                : AppColors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (payment.notes.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    payment.notes.replaceAll(RegExp(r'\r\n|\n'), ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          OutlinedButton(
            onPressed: () => Get.toNamed<void>(
              AppRouter.paymentReceipt,
              arguments: {'receiptId': payment.id},
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              side: BorderSide(color: AppColors.info),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(0, 32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LK.receipt.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: AppColors.info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String title) {
    if (title.toLowerCase().contains('life member')) return Icons.badge;
    if (title.toLowerCase().contains('membership')) return Icons.assignment;
    if (title.toLowerCase().contains('donation')) {
      return Icons.volunteer_activism;
    }
    if (title.toLowerCase().contains('temple')) return Icons.account_balance;
    return Icons.receipt;
  }

  Color _getIconColor(String title) {
    if (title.toLowerCase().contains('life member')) {
      return AppColors.orange.shade700;
    }
    if (title.toLowerCase().contains('membership')) {
      return AppColors.blue.shade700;
    }
    if (title.toLowerCase().contains('donation')) return Colors.teal;
    if (title.toLowerCase().contains('temple')) return AppColors.secondary;
    return AppColors.grey.shade700;
  }
}
