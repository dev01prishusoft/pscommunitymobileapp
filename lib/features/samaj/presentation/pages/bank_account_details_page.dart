import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/bank_account.dart';

class BankAccountDetailsPage extends StatelessWidget {
  const BankAccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bank = Get.arguments as BankAccount;

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
          LK.bankAccountDetails.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    bank.bankName,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  if (bank.isPrimary)
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        LK.primaryAccount.tr,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            _buildDetailsCard([
              _buildDetailItem(
                LK.accountHolderNameLabel.tr,
                bank.accountHolderName,
              ),
              _buildDetailItem(LK.accountNumberLabel.tr, bank.accountNumber, showCopyAction: true),
              _buildDetailItem(LK.accountTypeLabel.tr, bank.accountType),
              _buildDetailItem(LK.bankNameLabel.tr, bank.bankName),
              _buildDetailItem(LK.branchNameLabel.tr, bank.branchName),
              _buildDetailItem(LK.ifscCodeLabel.tr, bank.ifscCode, showCopyAction: true),
              _buildDetailItem(LK.micrCodeLabel.tr, bank.micrCode),
              _buildDetailItem(LK.swiftCodeLabel.tr, bank.swiftCode),
              _buildDetailItem(LK.upiIdLabel.tr, bank.upiId),
            ]),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    LK.scanToPay.tr,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 180.w,
                    height: 180.h,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 160,
                        color: AppColors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool showCopyAction = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          SizedBox(width: 8.w),
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
                    ),
                  ),
                ),
                if (showCopyAction && value.isNotEmpty) ...[
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        LK.success.tr,
                        '$label copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: AppColors.white,
                        margin: EdgeInsets.all(16),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 16.sp,
                      color: AppColors.primary,
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
