import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/features/member/controllers/profile_form_controller.dart';
import 'package:pscommunitymobileapp/core/models/address_model.dart';

/// Shared Addresses step used by both [EditProfilePage] and [AddFamilyMemberPage].
class ProfileAddressesStepSection extends StatelessWidget {
  const ProfileAddressesStepSection({
    super.key,
    required this.controller,
    this.getUpdateStatus,
    this.scrollController,
    this.onAddAddress,
    this.onDeleteAddress,
    this.isSameAsFamilyHead = false,
  });

  final ProfileFormController controller;
  final ProfileUpdateStatus? Function(String key, {Map<String, int>? idMap})?
  getUpdateStatus;
  final ScrollController? scrollController;
  final VoidCallback? onAddAddress;
  final void Function(int index)? onDeleteAddress;
  final bool isSameAsFamilyHead;

  bool get _isEditMode => getUpdateStatus != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: AppSpacing.pM,
      child: Obx(() {
        if (controller.addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 48,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LK.noAddressesYet.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  if (!_isEditMode && controller.showListErrors.value) ...[
                    const SizedBox(height: 8),
                    Text(
                      LK.addressRequiredError.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (onAddAddress != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onAddAddress,
                      icon: const Icon(Icons.add),
                      label: Text(LK.addAddress.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onAddAddress != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.addresses.length} ${LK.addressesTab.tr}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onAddAddress,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(LK.addAddress.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...List.generate(
              controller.addresses.length,
              (index) => _buildAddressItem(index),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAddressItem(int index) {
    final addr = controller.addresses[index];
    final bool isDisabled =
        _isEditMode && (!addr.isPrimary || isSameAsFamilyHead);

    final fieldsWidget = IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vS,
            Obx(() {
              final typeList = controller.contactInfo.addressTypeList;
              return AppFormDropdown<String>(
                value: typeList.contains(addr.type) ? addr.type : null,
                items: typeList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.tr,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    addr.type = v;
                    controller.addresses.refresh();
                  }
                },
                label: LK.addressType.tr,
                isRequired: true,
                requiredErrorMessage: LK.addressTypeRequired.tr,
                updateStatus: (addr.isPrimary && _isEditMode)
                    ? getUpdateStatus!(
                        'AddressTypeId',
                        idMap: controller.contactInfo.addressTypeIdMap,
                      )
                    : null,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              final stateList = controller.workStateList;
              return AppFormDropdown<String>(
                value: stateList.contains(addr.state) ? addr.state : null,
                items: stateList
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
                onChanged: (v) {
                  if (v != null) {
                    addr.state = v;
                    addr.stateId =
                        controller.workInfo.globalStateIdMap[v] ??
                        controller.workInfo.workStateIdMap[v];
                    addr.district = '';
                    addr.districtId = null;
                    addr.taluka = '';
                    addr.talukaId = null;
                    addr.area = '';
                    addr.areaId = null;
                    controller.addresses.refresh();
                  }
                },
                label: LK.state.tr,
                isRequired: true,
                updateStatus: (addr.isPrimary && _isEditMode)
                    ? getUpdateStatus!(
                        'StateId',
                        idMap: controller.workInfo.globalStateIdMap,
                      )
                    : null,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              final districtList = controller.getAddressDistricts(addr.state);
              return AppFormDropdown<String>(
                value: districtList.contains(addr.district)
                    ? addr.district
                    : null,
                items: districtList
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
                onChanged: (v) {
                  if (v != null) {
                    addr.district = v;
                    addr.districtId =
                        controller.workInfo.globalDistrictIdMap[v] ??
                        controller.workInfo.workDistrictIdMap[v];
                    addr.taluka = '';
                    addr.talukaId = null;
                    addr.area = '';
                    addr.areaId = null;
                    controller.addresses.refresh();
                  }
                },
                label: LK.district.tr,
                isRequired: true,
                updateStatus: (addr.isPrimary && _isEditMode)
                    ? getUpdateStatus!(
                        'DistrictId',
                        idMap: controller.workInfo.globalDistrictIdMap,
                      )
                    : null,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              final talukaList = controller.getAddressTalukas(addr.district);
              final displayTalukaList =
                  (addr.taluka.isNotEmpty && !talukaList.contains(addr.taluka))
                  ? [addr.taluka, ...talukaList]
                  : talukaList;
              return AppFormDropdown<String>(
                enableAdd: true,
                value: addr.taluka.isNotEmpty ? addr.taluka : null,
                isRequired:
                    controller.hasContactAddressChanged &&
                    addr.district.isNotEmpty,
                items: displayTalukaList
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
                onChanged: (v) {
                  if (v != null) {
                    addr.taluka = v;
                    addr.talukaId =
                        controller.workInfo.globalTalukaIdMap[v] ??
                        controller.workInfo.workTalukaIdMap[v] ??
                        0;
                    addr.area = '';
                    addr.areaId = null;
                    controller.addresses.refresh();
                  }
                },
                label: LK.taluka.tr,
                updateStatus: (addr.isPrimary && _isEditMode)
                    ? getUpdateStatus!(
                        'TalukaId',
                        idMap: controller.workInfo.globalTalukaIdMap,
                      )
                    : null,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              final areaList = controller.getAddressAreas(addr.taluka);
              final displayAreaList =
                  (addr.area.isNotEmpty && !areaList.contains(addr.area))
                  ? [addr.area, ...areaList]
                  : areaList;
              return AppFormDropdown<String>(
                enableAdd: true,
                value: addr.area.isNotEmpty ? addr.area : null,
                isRequired:
                    controller.hasContactAddressChanged &&
                    addr.taluka.isNotEmpty,
                items: displayAreaList
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
                onChanged: (v) {
                  if (v != null) {
                    addr.area = v;
                    addr.areaId =
                        controller.workInfo.globalAreaIdMap[v] ??
                        controller.workInfo.workAreaIdMap[v] ??
                        0;
                    controller.addresses.refresh();
                  }
                },
                label: LK.area.tr,
                updateStatus: (addr.isPrimary && _isEditMode)
                    ? getUpdateStatus!(
                        'AreaId',
                        idMap: controller.workInfo.globalAreaIdMap,
                      )
                    : null,
              );
            }),
            AppSpacing.vM,
            AppFormTextField(
              key: ValueKey('pincode_$index'),
              initialValue: addr.pincode,
              label: LK.pincode.tr,
              prefixIcon: const Icon(Icons.pin_drop_outlined),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              updateStatus: (addr.isPrimary && _isEditMode)
                  ? getUpdateStatus!('Pincode')
                  : null,
              onChanged: (v) {
                addr.pincode = v;
                controller.addresses.refresh();
              },
            ),
            AppSpacing.vM,
            AppFormTextField(
              key: ValueKey('line1_$index'),
              initialValue: addr.line1,
              label: LK.addressLine1.tr,
              isRequired: true,
              prefixIcon: const Icon(Icons.location_on_outlined),
              maxLength: 300,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 3,
              updateStatus: (addr.isPrimary && _isEditMode)
                  ? getUpdateStatus!('AddressLine1')
                  : null,
              onChanged: (v) {
                addr.line1 = v;
                controller.addresses.refresh();
              },
            ),
            AppSpacing.vM,
            AppFormTextField(
              key: ValueKey('line2_$index'),
              initialValue: addr.line2,
              label: LK.addressLine2.tr,
              prefixIcon: const Icon(Icons.location_on_outlined),
              maxLength: 300,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 3,
              updateStatus: (addr.isPrimary && _isEditMode)
                  ? getUpdateStatus!('AddressLine2')
                  : null,
              onChanged: (v) {
                addr.line2 = v;
                controller.addresses.refresh();
              },
            ),
            AppSpacing.vM,
            AppFormTextField(
              key: ValueKey('landmark_$index'),
              initialValue: addr.landmark,
              label: LK.landmarkLabel.tr,
              prefixIcon: const Icon(Icons.location_city_outlined),
              maxLength: 200,
              updateStatus: (addr.isPrimary && _isEditMode)
                  ? getUpdateStatus!('Landmark')
                  : null,
              onChanged: (v) {
                addr.landmark = v;
                controller.addresses.refresh();
              },
            ),
            AppSpacing.vM,
            _buildPrimaryCheckbox(addr),
          ],
        ),
      ),
    );

    if (!addr.isPrimary) {
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
          data: Theme.of(
            Get.context!,
          ).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            title: Text(
              '${LK.address.tr} #${index + 1}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            trailing: onDeleteAddress != null
                ? IconButton(
                    onPressed: () => onDeleteAddress!(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                      size: 20,
                    ),
                  )
                : null,
            childrenPadding: EdgeInsets.all(AppSpacing.m).copyWith(top: 0),
            children: [fieldsWidget],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      padding: AppSpacing.pM,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _isEditMode
                      ? '${LK.address.tr} #${index + 1}'
                      : '${LK.address.tr} #${index + 1} (${LK.primary.tr})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (onDeleteAddress != null)
                IconButton(
                  onPressed: () => onDeleteAddress!(index),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
          fieldsWidget,
        ],
      ),
    );
  }

  Widget _buildPrimaryCheckbox(AddressModel addr) {
    if (_isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: LK.primary.tr,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: addr.isPrimary,
                    onChanged: null,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled) &&
                          addr.isPrimary) {
                        return AppColors.primary.withValues(alpha: 0.5);
                      }
                      return null;
                    }),
                  ),
                ),
                AppSpacing.hS,
                Expanded(
                  child: Text(
                    LK.primary.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
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
            text: LK.isPrimary.tr,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            for (var a in controller.addresses) {
              a.isPrimary = false;
            }
            addr.isPrimary = true;
            controller.addresses.refresh();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: addr.isPrimary,
                    onChanged: (value) {
                      for (var a in controller.addresses) {
                        a.isPrimary = false;
                      }
                      addr.isPrimary = true;
                      controller.addresses.refresh();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                AppSpacing.hS,
                Text(LK.isPrimary.tr, style: AppTextStyles.titleSmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
