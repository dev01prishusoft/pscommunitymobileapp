import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/education_model.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/member/controllers/profile_form_controller.dart';

/// Shared Education step used by both [EditProfilePage] and [AddFamilyMemberPage].
class ProfileEducationStepSection extends StatelessWidget {
  const ProfileEducationStepSection({
    super.key,
    required this.controller,
    this.getUpdateStatus,
    this.scrollController,
    this.onAddEducation,
    this.onDeleteEducation,
  });

  final ProfileFormController controller;
  final ProfileUpdateStatus? Function(String key, {Map<String, int>? idMap})?
      getUpdateStatus;
  final ScrollController? scrollController;
  final VoidCallback? onAddEducation;
  final void Function(int index)? onDeleteEducation;

  bool get _isEditMode => getUpdateStatus != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: AppSpacing.pM,
      child: Obx(() {
        if (controller.educationList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isEditMode
                        ? 'No Education Details Found'
                        : LK.noEducationRecordsYet.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAddEducation ?? controller.addEducation,
                    icon: const Icon(Icons.add),
                    label: Text(LK.addEducation.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.educationList.length} ${LK.educationTab.tr}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onAddEducation ?? controller.addEducation,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(LK.addEducation.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...List.generate(
              controller.educationList.length,
              (index) => _buildEducationItem(index),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEducationItem(int index) {
    final edu = controller.educationList[index];
    final isHighest = edu.isHighest;
    final isNew = edu.isNew;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditMode
              ? AppColors.grey
              : AppColors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: _isEditMode
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Theme(
        data: Theme.of(Get.context!)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.primary,
          initiallyExpanded: isHighest,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          title: Text(
            '${LK.educationTab.tr} #${index + 1}${isHighest ? ' (${LK.highest.tr})' : ''}',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
          trailing: onDeleteEducation != null
              ? IconButton(
                  onPressed: () => onDeleteEducation!(index),
                  icon: Icon(Icons.delete_outline,
                      color: AppColors.red, size: 20),
                )
              : null,
          children: [
            Obx(
              () => AppFormDropdown<String>(
                value: (controller.qualificationList.isEmpty
                        ? controller.defaultQualifications
                        : controller.qualificationList)
                    .contains(edu.qualification)
                    ? edu.qualification
                    : null,
                items: (controller.qualificationList.isEmpty
                        ? controller.defaultQualifications
                        : controller.qualificationList)
                    .toSet()
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (!_isEditMode || isHighest)
                    ? (v) {
                        if (v != null) {
                          edu.qualification = v;
                          controller.educationList.refresh();
                        }
                      }
                    : null,
                label: LK.qualificationLabel.tr,
                updateStatus: (_isEditMode && isHighest && !isNew)
                    ? getUpdateStatus!(
                        'EducationalQualificationId',
                        idMap: controller.contactInfo.educationIdMap,
                      )
                    : null,
              ),
            ),
            AppSpacing.vM,
            AppFormTextField(
              initialValue: edu.institute,
              prefixIcon: const Icon(Icons.school_outlined),
              label: LK.instituteNameLabel.tr,
              updateStatus: (_isEditMode && isHighest && !isNew)
                  ? getUpdateStatus!('InstitutionName')
                  : null,
              maxLength: 300,
              readOnly: _isEditMode && !isHighest,
              onChanged: (!_isEditMode || isHighest)
                  ? (v) {
                      edu.institute = v;
                      controller.educationList.refresh();
                    }
                  : null,
            ),
            AppSpacing.vM,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppFormTextField(
                    initialValue: edu.passingYear,
                    prefixIcon: const Icon(Iconsax.calendar_copy),
                    label: LK.passingYearLabel.tr,
                    updateStatus: (_isEditMode && isHighest && !isNew)
                        ? getUpdateStatus!('YearOfPassing')
                        : null,
                    hint: 'YYYY',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (v.length != 4) {
                        return 'Passing Year must be exactly 4 digits';
                      }
                      final year = int.tryParse(v);
                      if (year != null) {
                        final currentYear = DateTime.now().year;
                        if (year > currentYear) {
                          return 'Passing Year cannot be greater than the current year';
                        }

                        final dobStr = controller.dobCtrl.text;
                        if (dobStr.isNotEmpty) {
                          try {
                            DateTime? dobDate;
                            if (dobStr.contains('-') &&
                                dobStr.split('-')[0].length == 2) {
                              final parts = dobStr.split('-');
                              dobDate = DateTime(
                                int.parse(parts[2]),
                                int.parse(parts[1]),
                                int.parse(parts[0]),
                              );
                            } else {
                              dobDate = DateTime.tryParse(dobStr);
                            }

                            if (dobDate != null && year < dobDate.year) {
                              return 'Passing Year cannot be before year of birth';
                            }
                          } catch (e, stack) {
                            CrashReporter.recordError(
                              e,
                              stack,
                              reason: 'Passing year date parse failed',
                            );
                          }
                        }
                      }
                      return null;
                    },
                    readOnly: _isEditMode && !isHighest,
                    onChanged: (!_isEditMode || isHighest)
                        ? (v) {
                            edu.passingYear = v;
                            controller.educationList.refresh();
                          }
                        : null,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: AppFormTextField(
                    initialValue: edu.percentage,
                    prefixIcon: const Icon(Iconsax.percentage_circle_copy),
                    label: LK.percentageLabel.tr,
                    updateStatus: (_isEditMode && isHighest && !isNew)
                        ? getUpdateStatus!('Percentage')
                        : null,
                    hint: '00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) return newValue;
                        final numVal = double.tryParse(newValue.text);
                        if (numVal != null && numVal > 100) return oldValue;
                        return newValue;
                      }),
                    ],
                    maxLength: 6,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final numVal = double.tryParse(v);
                        if (numVal != null && numVal > 100) {
                          return LK.cannotExceed100.tr;
                        }
                      }
                      return null;
                    },
                    readOnly: _isEditMode && !isHighest,
                    onChanged: (!_isEditMode || isHighest)
                        ? (v) {
                            edu.percentage = v;
                            controller.educationList.refresh();
                          }
                        : null,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: AppFormTextField(
                    initialValue: edu.grade,
                    label: 'Grade',
                    prefixIcon: const Icon(Iconsax.medal_copy),
                    updateStatus: (_isEditMode && isHighest && !isNew)
                        ? getUpdateStatus!('Grade')
                        : null,
                    maxLength: 10,
                    readOnly: _isEditMode && !isHighest,
                    onChanged: (!_isEditMode || isHighest)
                        ? (v) {
                            edu.grade = v;
                            controller.educationList.refresh();
                          }
                        : null,
                  ),
                ),
              ],
            ),
            AppSpacing.vM,
            AppFormTextField(
              initialValue: edu.description,
              label: 'Description',
              updateStatus: (_isEditMode && isHighest && !isNew)
                  ? getUpdateStatus!('Description')
                  : null,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 3,
              maxLength: 500,
              readOnly: _isEditMode && !isHighest,
              onChanged: (!_isEditMode || isHighest)
                  ? (v) {
                      edu.description = v;
                      controller.educationList.refresh();
                    }
                  : null,
            ),
            AppSpacing.vM,
            _buildHighestCheckbox(edu),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestCheckbox(EducationModel edu) {
    if (_isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: LK.markAsHighest.tr,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: edu.isHighest
                ? () {
                    PSDelightToastBar(
                      snackbarDuration: const Duration(seconds: 3),
                      builder: (context) => ToastCard(
                        title: LK.error.tr,
                        subtitle: LK.atLeastOneHighestQualification.tr,
                        isErrorMessage: true,
                      ),
                    ).show();
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: edu.isHighest
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: edu.isHighest,
                      onChanged: edu.isHighest
                          ? (value) {
                              PSDelightToastBar(
                                snackbarDuration: const Duration(
                                  seconds: 3,
                                ),
                                builder: (context) => ToastCard(
                                  title: LK.error.tr,
                                  subtitle: LK
                                      .atLeastOneHighestQualification
                                      .tr,
                                  isErrorMessage: true,
                                ),
                              ).show();
                            }
                          : null,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  AppSpacing.hS,
                  Expanded(
                    child: Text(
                      LK.markAsHighest.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: edu.isHighest
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: LK.isHighestQualification.tr,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            if (edu.isHighest) {
              PSDelightToastBar(
                snackbarDuration: const Duration(seconds: 3),
                builder: (context) => ToastCard(
                  title: LK.error.tr,
                  subtitle: LK.atLeastOneHighestQualification.tr,
                  isErrorMessage: true,
                ),
              ).show();
            } else {
              for (var e in controller.educationList) {
                e.isHighest = false;
              }
              edu.isHighest = true;
              controller.educationList.refresh();
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: edu.isHighest,
                    onChanged: (value) {
                      if (edu.isHighest && value == false) {
                        PSDelightToastBar(
                          snackbarDuration: const Duration(seconds: 3),
                          builder: (context) => ToastCard(
                            title: LK.error.tr,
                            subtitle: LK.atLeastOneHighestQualification.tr,
                            isErrorMessage: true,
                          ),
                        ).show();
                      } else if (!edu.isHighest && value == true) {
                        for (var e in controller.educationList) {
                          e.isHighest = false;
                        }
                        edu.isHighest = true;
                        controller.educationList.refresh();
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                AppSpacing.hS,
                Expanded(
                  child: Text(
                    LK.isHighestQualification.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
