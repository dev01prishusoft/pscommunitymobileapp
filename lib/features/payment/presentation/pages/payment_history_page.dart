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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.paymentHistory.tr,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildFilterDropdown(
                        label: '${LK.paymentTypeLabel.tr}:',
                        hint: LK.allTypes.tr,
                        value: controller.historyFilterType.value?.name,
                        items: controller.paymentTypes.map((t) => t.name).toList(),
                        onChanged: (val) {
                          if (val == null) {
                            controller.historyFilterType.value = null;
                          } else {
                            controller.historyFilterType.value = controller.paymentTypes.firstWhere((t) => t.name == val);
                          }
                          controller.loadHistory(paymentTypeId: controller.historyFilterType.value?.id);
                        },
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: '${LK.categoryLabel.tr}:',
                        hint: LK.allCategories.tr,
                        items: [], // Simplified for now
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildFilterDropdown(
                        label: '${LK.yearLabel.tr}:',
                        hint: '2025',
                        value: controller.selectedYear.value.isEmpty ? null : controller.selectedYear.value,
                        items: ['2025', '2024', '2023'],
                        onChanged: (val) {
                          controller.selectedYear.value = val ?? '';
                          controller.loadHistory(year: int.tryParse(val ?? ''));
                        },
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => _buildFilterDropdown(
                        label: '${LK.statusLabel.tr}:',
                        hint: LK.all.tr,
                        value: controller.selectedStatus.value,
                        items: ['All', 'Success', 'Pending', 'Failed'],
                        onChanged: (val) {
                          controller.selectedStatus.value = val ?? 'All';
                          controller.loadHistory(status: val);
                        },
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() => AppStateView(
              state: controller.historyState.value,
              onRetry: () => controller.loadHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.payments.length,
                itemBuilder: (context, index) {
                  final payment = controller.payments[index];
                  return _PaymentCard(payment: payment);
                },
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed<void>(AppRouter.makePayment),
        backgroundColor: const Color(0xFF29B6F6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                items: [
                  DropdownMenuItem(value: null, child: Text(hint)),
                  ...items.map((s) => DropdownMenuItem(value: s, child: Text(s))),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${payment.amount}  |  ${payment.date}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${payment.method}  |  ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      payment.status,
                      style: TextStyle(
                        color: payment.status.toLowerCase() == 'success' ? const Color(0xFF4CAF50) : Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => Get.toNamed<void>(AppRouter.paymentReceipt, arguments: {'receiptId': payment.id}),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              side: const BorderSide(color: Color(0xFF29B6F6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LK.receipt.tr,
                  style: const TextStyle(
                    color: Color(0xFF29B6F6),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF29B6F6)),
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
    if (title.toLowerCase().contains('donation')) return Icons.volunteer_activism;
    if (title.toLowerCase().contains('temple')) return Icons.account_balance;
    return Icons.receipt;
  }

  Color _getIconColor(String title) {
    if (title.toLowerCase().contains('life member')) return Colors.orange.shade700;
    if (title.toLowerCase().contains('membership')) return Colors.blue.shade700;
    if (title.toLowerCase().contains('donation')) return Colors.teal;
    if (title.toLowerCase().contains('temple')) return const Color(0xFF1E293B);
    return Colors.grey.shade700;
  }
}
