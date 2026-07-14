import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
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
          appBar: AppBar(
            title: Text(
              LK.samajInfo.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Container(
            color: AppColors.sfBackground,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppStateView(
                  state: AppState.loading,
                  child: SizedBox.shrink(),
                );
              }

              if (controller.bankdetailsError.value != null) {
                return AppStateView(
                  state: AppState.error,
                  errorMessage: controller.bankdetailsError.value,
                  onRetry: controller.fetchBankAccountDetail,
                  child: const SizedBox.shrink(),
                );
              }

              final accounts = controller.bankAccountDetails;

              if (accounts.isEmpty) {
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    _buildSamajCardSection(),
                    SizedBox(height: 24.h),
                    Text(
                      LK.bankAccounts.tr,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppStateView(
                      state: AppState.empty,
                      emptyMessage: LK.noBankAccountsFound.tr,
                      onRetry: controller.fetchBankAccountDetail,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: accounts.length + 1,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSamajCardSection(),
                        SizedBox(height: 24.h),
                        Text(
                          LK.bankAccounts.tr,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    );
                  }
                  final bank = accounts[index - 1];
                  return _buildBankCard(context, bank);
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSamajCardSection() {
    return GetX<SamajController>(
      builder: (controller) {
        final samaj = controller.samaj.value;
        if (samaj == null) return const SizedBox.shrink();
        return _ExpandableSamajCard(samaj: samaj);
      },
    );
  }

  Widget _buildBankCard(BuildContext context, SamajBankDetais bank) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      bank.bankName ?? '-',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (bank.isPrimary == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        LK.primary.tr,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.transparent),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(LK.branchLabel.tr, bank.branchName ?? '-'),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    LK.acLabel.tr,
                    bank.accountNumber ?? '-',
                    showCopy: true,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    LK.ifscLabel.tr,
                    bank.ifscCode ?? '-',
                    showCopy: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Divider(color: Colors.grey.shade100, height: 1),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed<void>(
                          AppRouter.bankAccountDetails,
                          arguments: bank,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              LK.viewDetails.tr,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (showCopy && value != '-' && value.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    PSDelightToastBar(
                      snackbarDuration: const Duration(seconds: 3),
                      builder: (context) => ToastCard(
                        title: '$label copied to clipboard',
                        subtitle: value,
                      ),
                    ).show();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14.sp,
                      color: AppColors.chart4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandableSamajCard extends StatefulWidget {
  const _ExpandableSamajCard({required this.samaj});

  final Samaj samaj;

  @override
  State<_ExpandableSamajCard> createState() => _ExpandableSamajCardState();
}

class _ExpandableSamajCardState extends State<_ExpandableSamajCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.samaj.description.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasDescription
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.samaj.logoUrl.isNotEmpty) ...[
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedImg(
                          url: widget.samaj.logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            'assets/images/prishusoft_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.samaj.name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (hasDescription) ...[
                          const SizedBox(height: 2),
                          Text(
                            _isExpanded
                                ? 'Tap to collapse'
                                : 'Tap to expand details',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasDescription)
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
              if (hasDescription)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isExpanded) ...[
                        SizedBox(height: 16.h),
                        Divider(color: Colors.grey.shade100, height: 1),
                        SizedBox(height: 12.h),
                        Text(
                          widget.samaj.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ] else ...[
                        const SizedBox.shrink(),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
