import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/bank_account_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

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
          appBar: AppBar(title: Text(LK.samajInfo.tr)),
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
              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildSamajCard(),
                  SizedBox(height: 24.h),
                  Text(
                    LK.bankAccounts.tr,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppStateView(
                    state: AppState.empty,
                    emptyMessage: LK.noBankAccountsFound.tr,
                    onRetry: controller.fetchBankAccountDetail,
                    child: SizedBox.shrink(),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(20),
              itemCount: accounts.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSamajCard(),
                      SizedBox(height: 24.h),
                      Text(
                        LK.bankAccounts.tr,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  );
                }
                final bank = accounts[index - 1];
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

  Widget _buildSamajCard() {
    return GetX<SamajController>(
      builder: (controller) {
        final samaj = controller.samaj.value;
        if (samaj == null) return const SizedBox.shrink();

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
                  if (samaj.logoUrl.isNotEmpty)
                    Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedImg(
                          url: samaj.logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (_, __, ___) => Image.asset('assets/images/prishusoft_logo.png',fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                  if (samaj.logoUrl.isNotEmpty) SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      samaj.name,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (samaj.description.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  samaj.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
