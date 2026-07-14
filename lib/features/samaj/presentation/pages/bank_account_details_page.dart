import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BankAccountDetailsPage extends StatelessWidget {
  const BankAccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SamajBankDetais bank = Get.arguments as SamajBankDetais;

    final upiUri = bank.upiId != null && 
            bank.upiId!.isNotEmpty && 
            bank.upiId != '-'
        ? 'upi://pay?pa=${bank.upiId}&pn=${Uri.encodeComponent(bank.accountHolderName ?? '')}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LK.bankAccountDetails.tr,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.sfBackground,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.wifi_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                        if (bank.isPrimary == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              LK.primary.tr.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      bank.accountNumber != null && bank.accountNumber!.length >= 4
                          ? bank.accountNumber!.replaceAllMapped(
                              RegExp(r".{4}"), (match) => "${match.group(0)}  ")
                          : bank.accountNumber ?? '-',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACCOUNT HOLDER',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bank.accountHolderName ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'BANK NAME',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bank.bankName ?? '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildDetailItem(
                      icon: Icons.person_outline_rounded,
                      label: LK.accountHolderNameLabel.tr,
                      value: bank.accountHolderName ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.credit_card_rounded,
                      label: LK.accountNumberLabel.tr,
                      value: bank.accountNumber ?? '-',
                      showCopyAction: true,
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: LK.accountTypeLabel.tr,
                      value: bank.accountType ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.account_balance_rounded,
                      label: LK.bankNameLabel.tr,
                      value: bank.bankName ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.business_rounded,
                      label: LK.branchNameLabel.tr,
                      value: bank.branchName ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.code_rounded,
                      label: LK.ifscCodeLabel.tr,
                      value: bank.ifscCode ?? '-',
                      showCopyAction: true,
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.qr_code_2_rounded,
                      label: LK.micrCodeLabel.tr,
                      value: bank.micrCode ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.swap_horizontal_circle_outlined,
                      label: LK.swiftCodeLabel.tr,
                      value: bank.swiftCode ?? '-',
                    ),
                    _buildDivider(),
                    _buildDetailItem(
                      icon: Icons.payment_rounded,
                      label: LK.upiIdLabel.tr,
                      value: bank.upiId ?? '-',
                      showCopyAction: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          LK.scanToPay.tr,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: upiUri != null
                          ? QrImageView(
                              data: upiUri,
                              version: QrVersions.auto,
                              size: 160.w,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: AppColors.secondary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: AppColors.secondary,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 120.w,
                                  color: Colors.grey.shade200,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'UPI ID not configured for payment QR code',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (upiUri != null) ...[
                      SizedBox(height: 12.h),
                      Text(
                        'Scan this QR code with any UPI app to pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100);
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool showCopyAction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showCopyAction && value != '-' && value.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        LK.success.tr,
                        '$label copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: AppColors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

