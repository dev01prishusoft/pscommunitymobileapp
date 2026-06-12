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
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final controller = Get.find<PaymentController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHistory();
    });
  }

  void _refreshHistory() {
    controller.loadHistory(
      paymentTypeId: controller.historyFilterType.value?.id,
      categoryId: controller.historyFilterCategory.value?.id,
      year: int.tryParse(controller.selectedYear.value),
      status: controller.selectedStatus.value,
    );
  }

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
                          label: LK.paymentTypeLabel.tr,
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
                          label: LK.categoryLabel.tr,
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
                      child: Obx(() {
                        final currentYear = DateTime.now().year;
                        final years = List.generate(5, (index) => (currentYear - index + 1).toString());
                        return _buildFilterDropdown(
                          label: LK.yearLabel.tr,
                          hint: currentYear.toString(),
                          value: controller.selectedYear.value.isEmpty
                              ? null
                              : controller.selectedYear.value,
                          items: years,
                          onChanged: (val) {
                            controller.selectedYear.value = val ?? '';
                            controller.loadHistory(
                              paymentTypeId: controller.historyFilterType.value?.id,
                              categoryId: controller.historyFilterCategory.value?.id,
                              year: int.tryParse(val ?? ''),
                              status: controller.selectedStatus.value,
                            );
                          },
                        );
                      }),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => _buildFilterDropdown(
                          label: LK.statusLabel.tr,
                          hint: LK.all.tr,
                          value: controller.selectedStatus.value == 'All' ? null : controller.selectedStatus.value,
                          items: ['Success', 'Pending', 'Failed'],
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
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
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
        onPressed: () async {
          await Get.toNamed<void>(AppRouter.makePayment);
          _refreshHistory();
        },
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
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.bold,
          ),
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
                    (s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? LK.all.tr : s)),
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
    final date = DateTime.tryParse(payment.date);
    final formattedDate = date != null ? DateFormat('dd/MM/yyyy hh:mm a').format(date) : payment.date;

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
          MemberAvatar(
            imageUrl: null,
            fallbackName: payment.title,
            radius: 22,
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
                  '₹${payment.amount}   $formattedDate',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      payment.rawStatus,
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
          SizedBox(width: 16.w),
          OutlinedButton(
            onPressed: () async {
              await Get.toNamed<void>(
                AppRouter.paymentReceipt,
                arguments: {'receiptId': payment.id},
              );
              await Get.find<PaymentController>().loadHistory(
                paymentTypeId: Get.find<PaymentController>().historyFilterType.value?.id,
                categoryId: Get.find<PaymentController>().historyFilterCategory.value?.id,
                year: int.tryParse(Get.find<PaymentController>().selectedYear.value),
                status: Get.find<PaymentController>().selectedStatus.value,
              );
            },
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

}
