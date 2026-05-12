import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_request.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/paid_payment_request.dart';

class PaymentsPage extends GetView<PaymentController> {
  const PaymentsPage({super.key});

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
          LK.payments.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Obx(() => AppStateView(
            state: controller.dashboardState.value,
            onRetry: controller.loadDashboard,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section - Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          label: LK.makePayment.tr,
                          icon: Icons.credit_card,
                          color: const Color(0xFF29B6F6),
                          onTap: () => Get.toNamed<void>(AppRouter.makePayment),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          label: LK.paymentHistory.tr,
                          icon: Icons.history,
                          color: const Color(0xFF4CAF50),
                          onTap: () => Get.toNamed<void>(AppRouter.paymentHistory),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Due Summary
                  if (controller.dashboard.value != null) ...[
                    _buildSectionHeader(LK.dueSummary.tr),
                    const SizedBox(height: 12),
                    _buildDueSummaryCard(),
                    const SizedBox(height: 24),
                  ],

                  // Requested Payments
                  if (controller.dashboard.value?.pendingPayments.isNotEmpty ?? false) ...[
                    _buildSectionHeader(
                      LK.requestedPayments.tr,
                      subtitle: '(${LK.adminSent.tr})',
                    ),
                    const SizedBox(height: 12),
                    ...controller.dashboard.value!.pendingPayments.map(
                      (req) => _buildPaymentRequestCard(req),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Paid Payments
                  if (controller.dashboard.value?.paidPayments.isNotEmpty ?? false) ...[
                    _buildSectionHeader(
                      LK.requestedPaymentsPaid.tr,
                      subtitle: '(${LK.adminSent.tr})',
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    ...controller.dashboard.value!.paidPayments.map(
                      (req) => _buildPaidPaymentCard(req),
                    ),
                  ],
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle, IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
        ],
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF29B6F6),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDueSummaryCard() {
    final dash = controller.dashboard.value!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LK.totalDue.tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${dash.totalDue}',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          if (dash.totalDue > 0)
            ElevatedButton(
              onPressed: () => controller.initiatePayment(customAmount: dash.totalDue),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(LK.payAll.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentRequestCard(PaymentRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconColor(req.title).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconData(req.title), color: _getIconColor(req.title)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      req.amountFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${LK.dueLabel.tr} ${req.dueDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.initiatePayment(adminPaymentRequestId: req.id),
            child: Row(
              children: [
                Text(
                  LK.payNowButton.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF29B6F6), fontSize: 13),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF29B6F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidPaymentCard(PaidPaymentRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      req.amountFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${LK.paidLabel.tr} ${req.paidDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed<void>(AppRouter.paymentReceipt, arguments: {'receiptId': req.receiptId}),
            child: Row(
              children: [
                Text(
                  LK.receipt.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF29B6F6), fontSize: 13),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF29B6F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String type) {
    if (type.toLowerCase().contains('life member')) return Icons.badge;
    if (type.toLowerCase().contains('membership')) return Icons.assignment;
    if (type.toLowerCase().contains('donation')) return Icons.account_balance;
    if (type.toLowerCase().contains('temple')) return Icons.account_balance;
    return Icons.receipt;
  }

  Color _getIconColor(String type) {
    if (type.toLowerCase().contains('life member')) return Colors.orange.shade700;
    if (type.toLowerCase().contains('membership')) return Colors.blueGrey;
    if (type.toLowerCase().contains('donation')) return Colors.teal;
    if (type.toLowerCase().contains('temple')) return const Color(0xFF1E293B);
    return Colors.grey.shade700;
  }
}
