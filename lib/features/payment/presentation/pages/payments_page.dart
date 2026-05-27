import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.payments.tr,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.secondary,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Obx(
        () => AppStateView(
          state: controller.dashboardState.value,
          onRetry: controller.loadDashboard,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        label: LK.makePayment.tr,
                        icon: Icons.credit_card,
                        color: AppColors.info,
                        onTap: () => Get.toNamed<void>(AppRouter.makePayment),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildQuickActionButton(
                        label: LK.paymentHistory.tr,
                        icon: Icons.history,
                        color: AppColors.success,
                        onTap: () =>
                            Get.toNamed<void>(AppRouter.paymentHistory),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                if (controller.dashboard.value != null) ...[
                  _buildSectionHeader(LK.dueSummary.tr),
                  SizedBox(height: 12.h),
                  _buildDueSummaryCard(),
                  SizedBox(height: 24.h),
                ],
                if (controller.dashboard.value?.pendingPayments.isNotEmpty ??
                    false) ...[
                  _buildSectionHeader(
                    LK.requestedPayments.tr,
                    subtitle: '(${LK.adminSent.tr})',
                  ),
                  SizedBox(height: 12.h),
                  ...controller.dashboard.value!.pendingPayments.map(
                    (req) => _buildPaymentRequestCard(req),
                  ),
                  SizedBox(height: 24.h),
                ],
                if (controller.dashboard.value?.paidPayments.isNotEmpty ??
                    false) ...[
                  _buildSectionHeader(
                    LK.requestedPaymentsPaid.tr,
                    subtitle: '(${LK.adminSent.tr})',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  ),
                  SizedBox(height: 12.h),
                  ...controller.dashboard.value!.paidPayments.map(
                    (req) => _buildPaidPaymentCard(req),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8.h),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: iconColor),
          SizedBox(width: 8.w),
        ],
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.info),
        ),
        if (subtitle != null) ...[
          SizedBox(width: 8.w),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildDueSummaryCard() {
    final dash = controller.dashboard.value!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              ),
              SizedBox(height: 4.h),
              Text(
                '₹${dash.totalDue}',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.destructive,
                ),
              ),
            ],
          ),
          if (dash.totalDue > 0)
            ElevatedButton(
              onPressed: () =>
                  controller.initiatePayment(customAmount: dash.totalDue),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(LK.payAll.tr, style: AppTextStyles.labelLarge),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentRequestCard(PaymentRequest req) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconColor(req.title).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconData(req.title),
              color: _getIconColor(req.title),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      req.amountFormatted,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${LK.dueLabel.tr} ${req.dueDate}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.destructive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                controller.initiatePayment(adminPaymentRequestId: req.id),
            child: Row(
              children: [
                Text(
                  LK.payNowButton.tr,
                  style: AppTextStyles.labelMedium.copyWith(
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

  Widget _buildPaidPaymentCard(PaidPaymentRequest req) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                if (req.memberName.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    req.memberName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      req.amountFormatted,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${LK.paidLabel.tr} ${req.paidDate}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed<void>(
              AppRouter.paymentReceipt,
              arguments: {'receiptId': req.receiptId},
            ),
            child: Row(
              children: [
                Text(
                  LK.receipt.tr,
                  style: AppTextStyles.labelMedium.copyWith(
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

  IconData _getIconData(String type) {
    if (type.toLowerCase().contains('life member')) return Icons.badge;
    if (type.toLowerCase().contains('membership')) return Icons.assignment;
    if (type.toLowerCase().contains('donation')) return Icons.account_balance;
    if (type.toLowerCase().contains('temple')) return Icons.account_balance;
    return Icons.receipt;
  }

  Color _getIconColor(String type) {
    if (type.toLowerCase().contains('life member')) {
      return AppColors.orange.shade700;
    }
    if (type.toLowerCase().contains('membership')) return AppColors.blueGrey;
    if (type.toLowerCase().contains('donation')) return Colors.teal;
    if (type.toLowerCase().contains('temple')) return AppColors.secondary;
    return AppColors.grey.shade700;
  }
}
