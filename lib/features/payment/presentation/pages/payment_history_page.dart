import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_category.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_type.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';

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
    controller.resetHistoryFilters();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHistory();
    });
  }

  void _refreshHistory() {
    controller.loadHistory(
      paymentTypeId: controller.historyFilterType.value?.id,
      categoryId: controller.historyFilterCategory.value?.id,
      year: int.tryParse(controller.selectedYear.value),
      status: controller.selectedStatus.value?['name'] as String?,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.paymentHistory.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filters',
            onPressed: () async {
              await Get.dialog<void>(
                _PaymentFilterDialog(onApply: _refreshHistory),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () => AppStateView(
          state: controller.historyState.value,
          onRetry: () => controller.loadHistory(),
          child: RefreshIndicator(
            onRefresh: () async => _refreshHistory(),
            color: AppColors.primary,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
                  controller.fetchMoreHistory();
                }
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                itemCount:
                    controller.payments.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.payments.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: AppLoadingIndicator(size: 24)),
                    );
                  }
                  final payment = controller.payments[index];
                  return _PaymentCard(payment: payment);
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          await Get.toNamed<void>(AppRouter.makePayment);
          controller.resetHistoryFilters();
          _refreshHistory();
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add_card_rounded, color: AppColors.white, size: 28),
        ),
      ),
    );
  }
}

class _PaymentFilterDialog extends StatefulWidget {
  const _PaymentFilterDialog({required this.onApply});

  final VoidCallback onApply;

  @override
  State<_PaymentFilterDialog> createState() => _PaymentFilterDialogState();
}

class _PaymentFilterDialogState extends State<_PaymentFilterDialog> {
  final controller = Get.find<PaymentController>();

  PaymentType? _tempType;
  PaymentCategory? _tempCategory;
  String _tempYear = '';
  Map<String, dynamic>? _tempStatus;

  @override
  void initState() {
    super.initState();
    _tempType = controller.historyFilterType.value;
    _tempCategory = controller.historyFilterCategory.value;
    _tempYear = controller.selectedYear.value;
    _tempStatus = controller.selectedStatus.value;

    if (_tempType != null) {
      controller.fetchHistoryCategories(_tempType!.id);
    }
  }

  bool get _hasSelection =>
      _tempType != null ||
      _tempCategory != null ||
      _tempYear.isNotEmpty ||
      _tempStatus != null;

  void _applyFilters() {
    controller.historyFilterType.value = _tempType;
    controller.historyFilterCategory.value = _tempCategory;
    controller.selectedYear.value = _tempYear;
    controller.selectedStatus.value = _tempStatus;
    Get.back<void>();
    widget.onApply();
  }

  void _resetFilters() {
    controller.resetHistoryFilters();
    Get.back<void>();
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        LK.paymentFilters.tr,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back<void>(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildDialogLabel(LK.paymentTypeLabel.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _buildDialogDropdown(
                    hint: LK.allTypes.tr,
                    value: _tempType?.name,
                    items: controller.paymentTypes.map((t) => t.name).toList(),
                    onChanged: (val) async {
                      if (val == null) {
                        setState(() {
                          _tempType = null;
                          _tempCategory = null;
                        });
                        controller.historyCategories.clear();
                      } else {
                        final selectedType = controller.paymentTypes.firstWhere(
                          (t) => t.name == val,
                        );
                        setState(() {
                          _tempType = selectedType;
                          _tempCategory = null;
                        });
                        await controller.fetchHistoryCategories(
                          selectedType.id,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                _buildDialogLabel(LK.categoryLabel.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _buildDialogDropdown(
                    hint: LK.allCategories.tr,
                    value: _tempCategory?.name,
                    items: controller.historyCategories
                        .map((c) => c.name)
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          _tempCategory = null;
                        } else {
                          _tempCategory = controller.historyCategories
                              .firstWhere((c) => c.name == val);
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel(LK.yearLabel.tr),
                          SizedBox(height: 6.h),
                          Builder(
                            builder: (_) {
                              final currentYear = DateTime.now().year;
                              final years = List.generate(
                                5,
                                (index) => (currentYear - index + 1).toString(),
                              );
                              return _buildDialogDropdown(
                                hint: LK.all.tr,
                                value: _tempYear.isEmpty ? null : _tempYear,
                                items: years,
                                onChanged: (val) {
                                  setState(() {
                                    _tempYear = val ?? '';
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel(LK.statusLabel.tr),
                          SizedBox(height: 6.h),
                          Obx(
                            () => _buildDialogDropdown(
                              hint: LK.all.tr,
                              value: _tempStatus?['name'] as String?,
                              items: controller.paymentStatuses
                                  .map((s) => s['name'] as String)
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  if (val == null) {
                                    _tempStatus = null;
                                  } else {
                                    _tempStatus = controller.paymentStatuses
                                        .firstWhere((s) => s['name'] == val);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(LK.applyFilters.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                  ),
                ),
                if (_hasSelection) ...[
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey.shade700,
                        side: BorderSide(color: AppColors.grey.shade400, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        LK.reset.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDialogDropdown({
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    String? value,
  }) {
    return Container(
      height: 48.h,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.grey.shade50,
        border: Border.all(
          color: value != null
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: (value != null && items.contains(value)) ? value : null,
          hint: Text(
            hint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey.shade400,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                hint,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey.shade400,
                ),
              ),
            ),
            ...items.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(
                  s == 'All' ? LK.all.tr : s,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentItem payment;

  @override
  Widget build(BuildContext context) {
    DateTime? date;
    final str = payment.date;
    if (str.endsWith('Z') || str.contains(RegExp(r'[+-]\d{2}:\d{2}$'))) {
      date = DateTime.tryParse(str)?.toLocal();
    } else {
      try {
        if (str.contains('/')) {
          date = DateFormat('dd/MM/yyyy hh:mm a').parse(str, true).toLocal();
        } else if (str.contains(RegExp(r'^\d{2}-\d{2}-\d{4}'))) {
          date = DateFormat('dd-MM-yyyy HH:mm:ss').parse(str, true).toLocal();
        } else {
          date = DateTime.parse('${str}Z').toLocal();
        }
      } catch (_) {
        date = DateTime.tryParse(str)?.toLocal();
      }
    }

    final formattedDate = date != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(date)
        : payment.date;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MemberAvatar(
                      imageUrl: payment.memberImageUrl.isNotEmpty
                          ? payment.memberImageUrl
                          : null,
                      fallbackName: payment.title,
                      radius: 22,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${payment.amount}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            payment.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    InkWell(
                      onTap: () async {
                        await Get.toNamed<void>(
                          AppRouter.paymentReceipt,
                          arguments: {
                            'receiptId': payment.id,
                            'isRecurring': payment.isRecurring,
                            'planName': payment.planName,
                          },
                        );
                        Get.find<PaymentController>().resetHistoryFilters();
                        await Get.find<PaymentController>().loadHistory();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LK.receipt.tr,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${payment.type} (${payment.method})',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: payment.status == PaymentStatus.success
                            ? Colors.green.shade50
                            : payment.status == PaymentStatus.failed
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: payment.status == PaymentStatus.success
                              ? Colors.green.withValues(alpha: 0.2)
                              : payment.status == PaymentStatus.failed
                              ? Colors.red.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        payment.rawStatus,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: payment.status == PaymentStatus.success
                              ? AppColors.green
                              : payment.status == PaymentStatus.failed
                              ? AppColors.red
                              : AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (payment.isRecurring) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.autorenew_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              payment.planName.isNotEmpty
                                  ? payment.planName
                                  : LK.recurring.tr,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (payment.notes.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 3.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.notes.replaceAll(RegExp(r'\r\n|\n'), ' '),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
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
