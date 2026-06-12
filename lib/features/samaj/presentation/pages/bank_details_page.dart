import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/bank_account_controller.dart';

class BankDetailsPage extends StatelessWidget {
  const BankDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BankAccountController>(
      initState: (state) {
        Future.microtask(() {
          state.controller?.fetchBankAccountDetail();
        });
      },
      builder: (controller) {
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
              LK.bankAccounts.tr,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
              ),
            ),
            centerTitle: false,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return AppStateView(
                state: AppState.loading,
                child: SizedBox.shrink(),
              );
            }

            if (controller.bankdetailsError.value != null) {
              return AppStateView(
                state: AppState.error,
                errorMessage: controller.bankdetailsError.value,
                onRetry: controller.fetchBankAccountDetail,
                child: SizedBox.shrink(),
              );
            }

            final accounts = controller.bankAccountDetails;

            if (accounts.isEmpty) {
              return AppStateView(
                state: AppState.empty,
                emptyMessage: LK.noBankAccountsFound.tr,
                onRetry: controller.fetchBankAccountDetail,
                child: SizedBox.shrink(),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(20),
              itemCount: accounts.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final bank = accounts[index];
                return _buildBankCard(context, bank);
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildBankCard(BuildContext context, SamajBankDetais bank) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.bankName ?? '-',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (bank.isPrimary == true)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    LK.primary.tr,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.deepGreen,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildDetailRow(LK.branchLabel.tr, bank.branchName ?? '-'),
          _buildDetailRow(LK.acLabel.tr, bank.accountNumber ?? '-'),
          _buildDetailRow(LK.ifscLabel.tr, bank.ifscCode ?? '-'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          InkWell(
            onTap: () {
              Get.toNamed<void>(AppRouter.bankAccountDetails, arguments: bank);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  LK.viewDetails.tr,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.deepBlue,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward, color: AppColors.deepBlue, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
