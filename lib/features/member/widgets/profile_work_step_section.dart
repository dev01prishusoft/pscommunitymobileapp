import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/features/member/controllers/profile_form_controller.dart';

/// Shared Work & Assets step used by both [EditProfilePage] and
/// [AddFamilyMemberPage].
///
/// [getUpdateStatus] is only supplied by [EditProfilePage] to show
/// pending-update badges. Leave it null (the default) for the add-member flow.
class ProfileWorkStepSection extends StatelessWidget {
  const ProfileWorkStepSection({
    super.key,
    required this.controller,
    this.getUpdateStatus,
  });

  final ProfileFormController controller;

  /// Returns a [ProfileUpdateStatus] for the given field key, or null.
  /// When null, no badge is shown.
  final ProfileUpdateStatus? Function(
    String key, {
    Map<String, int>? idMap,
  })? getUpdateStatus;

  ProfileUpdateStatus? _status(String key, {Map<String, int>? idMap}) =>
      getUpdateStatus?.call(key, idMap: idMap);

  Widget _buildFieldPair(Widget child1, Widget child2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child1),
        SizedBox(width: AppSpacing.m),
        Expanded(child: child2),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: AppSpacing.pL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        AppSpacing.hM,
        Text(title, style: AppTextStyles.headlineSmall),
      ],
    );
  }

  Widget _buildCheckbox(String label, RxBool value) {
    return Obx(
      () => CheckboxListTile(
        value: value.value,
        onChanged: (v) => value.value = v ?? false,
        title: Text(label, style: AppTextStyles.bodyMedium),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pM,
      child: Column(
        children: [
          _buildAssetsCard(),
          AppSpacing.vM,
          _buildWorkCard(),
        ],
      ),
    );
  }

  Widget _buildAssetsCard() {
    return _buildCard(
      children: [
        _buildSectionHeader(
          Icons.account_balance_wallet_outlined,
          LK.assetsLife.tr,
        ),
        const Divider(height: 24),
        // Each checkbox has its own Obx; an outer Obx here would observe
        // nothing and throw "improper use of GetX".
        _buildFieldPair(
          _buildCheckbox(LK.ownLand.tr, controller.personalInfo.ownLand),
          _buildCheckbox(LK.ownHouse.tr, controller.personalInfo.ownHouse),
        ),
        _buildFieldPair(
          _buildCheckbox(LK.twoWheeler.tr, controller.personalInfo.twoWheeler),
          _buildCheckbox(LK.fourWheeler.tr, controller.personalInfo.fourWheeler),
        ),
        AppSpacing.vM,
        Obx(() {
          // Touch fieldStatuses so Obx always has an observable, even when
          // no getUpdateStatus callback is supplied.
          controller.fieldStatuses.length;
          return AppFormTextField(
            controller: controller.personalInfo.monthlyIncomeCtrl,
            label: LK.monthlyIncomeLabel.tr,
            prefixIcon: const Icon(Icons.currency_rupee),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            maxLength: 13,
            updateStatus: _status('MonthlyIncome'),
          );
        }),
      ],
    );
  }

  Widget _buildWorkCard() {
    return _buildCard(
      children: [
        _buildSectionHeader(Icons.work_outline, LK.workHistory.tr),
        const Divider(height: 24),
        Obx(() {
          final list = controller.workInfo.occupationTypeList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.occupationType.value)
                ? controller.workInfo.occupationType.value
                : null,
            items: list
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupationType.value = v;
            },
            label: LK.occupationType.tr,
            isRequired: true,
            originalValue: controller.currentMember?.occupationTypeName ?? '',
            updateStatus: _status(
              'OccupationTypeId',
              idMap: controller.workInfo.occupationTypeIdMap,
            ),
          );
        }),
        AppSpacing.vM,
        Obx(() {
          final list = controller.workInfo.occupationList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.occupation.value)
                ? controller.workInfo.occupation.value
                : null,
            items: list
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupation.value = v;
            },
            label: LK.occupation.tr,
            isRequired: true,
            originalValue: controller.currentMember?.occupationName ?? '',
            validator: getUpdateStatus != null
                ? (v) {
                    final initialType =
                        controller.getInitialDropdownValue('OccupationTypeId');
                    final currentType = controller.workInfo.occupationType.value;
                    if (initialType != currentType &&
                        currentType.isNotEmpty &&
                        (v == null || v.isEmpty)) {
                      return LK.fieldRequired.tr;
                    }
                    return null;
                  }
                : null,
            updateStatus: _status(
              'OccupationId',
              idMap: controller.workInfo.occupationIdMap,
            ),
          );
        }),
        AppSpacing.vM,
        Obx(() {
          final list = controller.workInfo.jobPositionList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.jobPosition.value)
                ? controller.workInfo.jobPosition.value
                : null,
            items: list
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.jobPosition.value = v;
            },
            label: LK.jobPositionLabel.tr,
            originalValue: controller.currentMember?.jobPositionName ?? '',
            updateStatus: _status(
              'JobPositionId',
              idMap: controller.workInfo.jobPositionIdMap,
            ),
          );
        }),
        AppSpacing.vM,
        Obx(
          () => AppFormTextField(
            prefixIcon: const Icon(Iconsax.personalcard_copy),
            controller: controller.otherOccupationCtrl,
            label: LK.otherOccupationLabel.tr,
            maxLength: 200,
            onChanged: (v) => controller.workInfo.otherOccupation.value = v,
            updateStatus: _status('OtherOccupation'),
          ),
        ),
        AppSpacing.vM,
        _buildFieldPair(
          Obx(
            () => AppFormTextField(
              controller: controller.companyNameCtrl,
              label: LK.companyNameLabel.tr,
              prefixIcon: const Icon(Iconsax.buildings_copy),
              maxLength: 200,
              onChanged: (v) => controller.companyName.value = v,
              updateStatus: _status('CompanyName'),
            ),
          ),
          Obx(
            () => AppFormTextField(
              controller: controller.businessNameCtrl,
              label: LK.businessName.tr,
              prefixIcon: const Icon(Iconsax.briefcase_copy),
              maxLength: 200,
              onChanged: (v) => controller.businessName.value = v,
              updateStatus: _status('BusinessName'),
            ),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormTextField(
            controller: controller.occupationDescriptionCtrl,
            label: LK.occupationDescriptionLabel.tr,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 3,
            maxLength: 500,
            updateStatus: _status('OccupationDescription'),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormDropdown<String>(
            value: controller.workStateList.contains(controller.workState.value)
                ? controller.workState.value
                : null,
            items: controller.workStateList
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workState.value = v;
            },
            label: LK.state.tr,
            updateStatus: _status(
              'OccupationStateId',
              idMap: controller.workInfo.workStateIdMap,
            ),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormDropdown<String>(
            value: controller.workDistrictList.contains(controller.workDistrict.value)
                ? controller.workDistrict.value
                : null,
            items: controller.workDistrictList
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workDistrict.value = v;
            },
            label: LK.district.tr,
            updateStatus: _status(
              'OccupationDistrictId',
              idMap: controller.workInfo.workDistrictIdMap,
            ),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormDropdown<String>(
            value: controller.workTalukaList.contains(controller.workTaluka.value)
                ? controller.workTaluka.value
                : null,
            isRequired: controller.hasWorkAddressChanged &&
                controller.workDistrict.value.isNotEmpty,
            items: controller.workTalukaList
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workTaluka.value = v;
            },
            label: LK.taluka.tr,
            updateStatus: _status(
              'OccupationTalukaId',
              idMap: controller.workInfo.workTalukaIdMap,
            ),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormDropdown<String>(
            value: controller.workAreaList.contains(controller.workArea.value)
                ? controller.workArea.value
                : null,
            isRequired: controller.hasWorkAddressChanged &&
                controller.workTaluka.value.isNotEmpty,
            items: controller.workAreaList
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.workArea.value = v;
            },
            label: LK.area.tr,
            updateStatus: _status(
              'OccupationAreaId',
              idMap: controller.workInfo.workAreaIdMap,
            ),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormTextField(
            controller: controller.workAddressLine1Ctrl,
            label: LK.occupationAddressLine1Label.tr,
            prefixIcon: const Icon(Icons.location_on_outlined),
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 3,
            onChanged: (v) => controller.workAddressLine1.value = v,
            updateStatus: _status('OccupationAddressLine1'),
          ),
        ),
        AppSpacing.vM,
        Obx(
          () => AppFormTextField(
            controller: controller.workAddressLine2Ctrl,
            label: LK.occupationAddressLine2Label.tr,
            prefixIcon: const Icon(Icons.location_on_outlined),
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 3,
            onChanged: (v) => controller.workAddressLine2.value = v,
            updateStatus: _status('OccupationAddressLine2'),
          ),
        ),
        AppSpacing.vM,
        _buildFieldPair(
          Obx(
            () => AppFormTextField(
              controller: controller.workLandmarkCtrl,
              label: LK.landmarkLabel.tr,
              prefixIcon: const Icon(Icons.location_city_outlined),
              maxLength: 200,
              onChanged: (v) => controller.workLandmark.value = v,
              updateStatus: _status('OccupationLandmark'),
            ),
          ),
          Obx(
            () => AppFormTextField(
              controller: controller.workPincodeCtrl,
              label: LK.pincode.tr,
              prefixIcon: const Icon(Icons.pin_drop_outlined),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              onChanged: (v) => controller.workPincode.value = v,
              updateStatus: _status('OccupationPincode'),
            ),
          ),
        ),
      ],
    );
  }
}
