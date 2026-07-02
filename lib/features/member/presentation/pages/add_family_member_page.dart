import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/utils/app_formatters.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_date_picker.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_time_picker.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  late final ProfileFormController controller;
  final ScrollController _scrollController = ScrollController();

  late String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = UniqueKey().toString();
    controller = Get.put(ProfileFormController(), tag: controllerTag);
    controller.markAsAddMode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<ProfileFormController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(title: Text(LK.addFamilyMember.tr)),
      body: Obx(() => Form(
        key: controller.formKey,
        autovalidateMode: controller.showListErrors.value 
            ? AutovalidateMode.always 
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildProfilePhotoSection(),
              _buildSection(LK.personal.tr, Icons.person_outline, [
                AppFormTextField(
                  controller: controller.memberNoCtrl,
                  label: LK.memberNo.tr,
                  hint: 'Auto Generated Code',
                  readOnly: true,
                ),
                AppSpacing.vM,

                AppFormTextField(
                  controller: controller.firstNameCtrl,
                  label: LK.firstName.tr,
                  isRequired: true,
                  prefixIcon: Icon(Icons.person),
                  maxLength: 100,
                ),
                AppSpacing.vM,
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.middleNameCtrl,
                    label: LK.middleName.tr,
                    prefixIcon: Icon(Icons.person_outline),
                    maxLength: 100,
                  ),
                  AppFormTextField(
                    controller: controller.lastNameCtrl,
                    label: LK.lastName.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.person),
                    maxLength: 100,
                  ),
                ),
                AppSpacing.vM,
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.firstNameEnCtrl,
                    label: LK.firstNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.language),
                    maxLength: 100,
                  ),
                  AppFormTextField(
                    controller: controller.lastNameEnCtrl,
                    label: LK.lastNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.language),
                    maxLength: 100,
                  ),
                ),
                AppSpacing.vM,
                _buildFieldPair(
                  AppFormDatePicker(
                    controller: controller.dobCtrl,
                    label: LK.birthDate.tr,
                    lastDate: DateTime.now(),
                  ),
                  AppFormTimePicker(
                    controller: controller.tobCtrl,
                    label: LK.timeOfBirth.tr,
                  ),
                ),
                _buildFieldPair(
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.genderList.contains(
                            controller.gender.value,
                          )
                          ? controller.gender.value
                          : null,
                      items:
                          (controller.genderList.isEmpty
                                  ? controller.defaultGenders
                                  : controller.genderList)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.tr),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => controller.gender.value = v!,
                      label: LK.gender.tr,
                      isRequired: true,
                    ),
                  ),
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.maritalStatusList.contains(
                            controller.maritalStatus.value,
                          )
                          ? controller.maritalStatus.value
                          : null,
                      items:
                          (controller.maritalStatusList.isEmpty
                                  ? controller.defaultMaritalStatuses
                                  : controller.maritalStatusList)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.tr),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        controller.maritalStatus.value = v!;
                        if (controller.shouldHideLookingForMarriage) {
                          controller.openToMarriage.value = false;
                        }
                      },
                      label: LK.maritalStatusLabel.tr,
                      isRequired: true,
                    ),
                  ),
                ),
                _buildFieldPair(
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.bloodGroupList.contains(
                            controller.bloodGroup.value,
                          )
                          ? controller.bloodGroup.value
                          : null,
                      items:
                          (controller.bloodGroupList.isEmpty
                                  ? controller.defaultBloodGroups
                                  : controller.bloodGroupList)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)),
                              )
                              .toList(),
                      onChanged: (v) => controller.bloodGroup.value = v!,
                      label: LK.bloodGroup.tr,
                    ),
                  ),
                  Obx(
                    () => AppFormDropdown<String>(
                      value: controller.signList.contains(controller.sign.value)
                          ? controller.sign.value
                          : null,
                      items:
                          (controller.signList.isEmpty
                                  ? controller.defaultSigns
                                  : controller.signList)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)),
                              )
                              .toList(),
                      onChanged: (v) => controller.sign.value = v!,
                      label: LK.sign.tr,
                    ),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.weightCtrl,
                    label: LK.weightKg.tr,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalAutoInsertFormatter()],
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    maxLength: 6,
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.replaceAll('.', '').length > 5) {
                        return 'Max 5 digits allowed';
                      }
                      return null;
                    },
                  ),
                  AppFormTextField(
                    controller: controller.heightCtrl,
                    label: LK.heightCm.tr,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalAutoInsertFormatter()],
                    prefixIcon: Icon(Icons.height),
                    maxLength: 6,
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.replaceAll('.', '').length > 5) {
                        return 'Max 5 digits allowed';
                      }
                      return null;
                    },
                  ),
                ),
              ]),

              _buildSection(LK.contactVerify.tr, Icons.contact_phone_outlined, [
                AppFormTextField(
                  controller: controller.mobileCtrl,
                  label: LK.mobileNo.tr,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.phone),
                  maxLength: 10,
                  validator: AppValidators.mobile,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.phone_android),
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emailCtrl,
                  label: LK.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                  maxLength: 200,
                  validator: AppValidators.optionalEmail,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.entryPersonMobileCtrl,
                  label: LK.entryPersonMobile.tr,
                  prefixIcon: Icon(Icons.phone_callback),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emergencyNameCtrl,
                  label: LK.emergencyContactNameLabel.tr,
                  prefixIcon: Icon(Icons.person_add_alt_1),
                  maxLength: 100,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.emergency_outlined),
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
              ]),

              _buildSection(
                LK.familyParents.tr,
                Icons.family_restroom_outlined,
                [
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.relationList.contains(
                            controller.relation.value,
                          )
                          ? controller.relation.value
                          : null,
                      items:
                          (controller.relationList.isEmpty
                                  ? controller.defaultRelations
                                  : controller.relationList)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.tr),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => controller.relation.value = v!,
                      label: LK.relation.tr,
                      isRequired: true,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppFormTextField(
                    controller: controller.motherFatherNameCtrl,
                    label: LK.motherFatherName.tr,
                    prefixIcon: Icon(Icons.people_outline),
                    maxLength: 100,
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldPair(
                    Obx(
                      () => AppFormDropdown<String>(
                        value: controller.gotraList.contains(controller.gotra.value)
                            ? controller.gotra.value
                            : null,
                        items: controller.gotraList
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.gotra.value = v;
                        },
                        label: LK.gotraLabel.tr,
                      ),
                    ),
                    Obx(
                      () => AppFormDropdown<String>(
                        value: controller.mothersGotraList.contains(controller.mothersGotra.value)
                            ? controller.mothersGotra.value
                            : null,
                        items: controller.mothersGotraList
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.mothersGotra.value = v;
                        },
                        label: LK.mothersGotra.tr,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final stateList = controller.workStateList;
                    return AppFormDropdown<String>(
                      value: stateList.contains(controller.personalInfo.motherState.value)
                          ? controller.personalInfo.motherState.value
                          : null,
                      items: stateList
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.personalInfo.motherState.value = v;
                          controller.personalInfo.motherDistrict.value = '';
                          controller.personalInfo.motherTaluka.value = '';
                          controller.personalInfo.motherArea.value = '';
                        }
                      },
                      label: LK.mothersState.tr,
                    );
                  }),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final districtList = controller.getAddressDistricts(controller.personalInfo.motherState.value);
                    return AppFormDropdown<String>(
                      value: districtList.contains(controller.personalInfo.motherDistrict.value)
                          ? controller.personalInfo.motherDistrict.value
                          : null,
                      items: districtList
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.personalInfo.motherDistrict.value = v;
                          controller.personalInfo.motherTaluka.value = '';
                          controller.personalInfo.motherArea.value = '';
                        }
                      },
                      label: LK.mothersDistrict.tr,
                    );
                  }),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final talukaList = controller.getAddressTalukas(controller.personalInfo.motherDistrict.value);
                    return AppFormDropdown<String>(
                      value: talukaList.contains(controller.personalInfo.motherTaluka.value)
                          ? controller.personalInfo.motherTaluka.value
                          : null,
                      items: talukaList
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.personalInfo.motherTaluka.value = v;
                          controller.personalInfo.motherArea.value = '';
                        }
                      },
                      label: LK.mothersTaluka.tr,
                    );
                  }),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final areaList = controller.getAddressAreas(controller.personalInfo.motherTaluka.value);
                    return AppFormDropdown<String>(
                      value: areaList.contains(controller.personalInfo.motherArea.value)
                          ? controller.personalInfo.motherArea.value
                          : null,
                      items: areaList
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.personalInfo.motherArea.value = v;
                        }
                      },
                      label: LK.mothersArea.tr,
                    );
                  }),
                  Obx(() {
                    if (controller.shouldHideLookingForMarriage) {
                      return SizedBox.shrink();
                    }
                    return _buildCheckbox(LK.lookingForMarriage.tr, controller.openToMarriage);
                  }),
                ],
              ),

              _buildAssetsLifeSection(),

              _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
                AppFormTextField(
                  controller: controller.facebookCtrl,
                  label: LK.facebook.tr,
                  prefixIcon: Icon(Icons.facebook),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.whatsappCtrl,
                  label: LK.whatsapp.tr,
                  prefixIcon: Icon(Icons.chat),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.instagramCtrl,
                  label: LK.instagram.tr,
                  prefixIcon: Icon(Icons.camera_alt),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.twitterCtrl,
                  label: LK.twitterX.tr,
                  prefixIcon: Icon(Icons.close),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
              ]),

              _buildAddressesSection(),
              _buildEducationSection(),
              _buildWorkHistorySection(),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      )),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Obx(
              () => AppPrimaryButton(
                text: LK.saveChanges.tr,
                onPressed: () => controller.submitForm(successMessage: LK.memberAddedSuccessfully.tr),
                isLoading: controller.isFormLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldPair(Widget child1, Widget child2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          SizedBox(width: 12.w),
          Expanded(child: child2),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(LK.profilePhoto.tr, style: AppTextStyles.headlineSmall),
          SizedBox(height: 16.h),
          Center(
            child: Stack(
              children: [
                Obx(() {
                  final file = controller.profileImage.value;
                  return Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 4.w,
                      ),
                      image: file != null
                          ? DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: file == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.mutedForeground,
                          )
                        : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20.r,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: AppColors.white,
                      ),
                      onPressed: controller.pickProfilePhoto,
                    ),
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 16.h),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.memberNoCtrl,
            builder: (context, value, child) {
              if (value.text.isEmpty) return SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LK.memberNo.tr.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          value.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, RxBool value) {
    return Obx(
      () => InkWell(
        onTap: () => value.value = !value.value,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                height: 24.h,
                width: 24.w,
                child: Checkbox(
                  value: value.value,
                  onChanged: (v) => value.value = v!,
                  activeColor: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(label, style: AppTextStyles.titleSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesSection() {
    return Obx(
      () => _buildSection(LK.addressesTab.tr, Icons.location_on_outlined, [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.addresses.length} ${LK.addressesTab.tr}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            TextButton.icon(
              onPressed: controller.addAddress,
              icon: Icon(Icons.add, size: 18),
              label: Text(LK.addAddress.tr),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (controller.addresses.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    LK.noAddressesYet.tr,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground),
                  ),
                  if (controller.showListErrors.value) ...[
                    SizedBox(height: 4.h),
                    Text(
                      LK.addressRequiredError.tr,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.red),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          ...List.generate(
            controller.addresses.length,
            (index) => _buildAddressItem(index),
          ),
      ]),
    );
  }

  Widget _buildAddressItem(int index) {
    final addr = controller.addresses[index];
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${LK.address.tr} #${index + 1}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.removeAddress(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.destructive,
                  size: 20,
                ),
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final typeList = controller.addressTypeList;
            return AppFormDropdown<String>(
              value: typeList.contains(addr.type)
                  ? addr.type
                  : null,
              items: typeList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
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
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final stateList = controller.workStateList;
            return AppFormDropdown<String>(
              value: stateList.contains(addr.state)
                  ? addr.state
                  : null,
              items: stateList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.state = v;
                  addr.district = '';
                  addr.taluka = '';
                  addr.area = '';
                  controller.addresses.refresh();
                }
              },
              label: LK.state.tr,
              isRequired: true,
              requiredErrorMessage: LK.stateRequired.tr,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final districtList = controller.getAddressDistricts(addr.state);
            return AppFormDropdown<String>(
              value: districtList.contains(addr.district)
                  ? addr.district
                  : null,
              items: districtList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.district = v;
                  addr.taluka = '';
                  addr.area = '';
                  controller.addresses.refresh();
                }
              },
              label: LK.district.tr,
              isRequired: true,
              requiredErrorMessage: LK.districtRequired.tr,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final talukaList = controller.getAddressTalukas(addr.district);
            return AppFormDropdown<String>(
              value: talukaList.contains(addr.taluka)
                  ? addr.taluka
                  : null,
              items: talukaList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.taluka = v;
                  addr.area = '';
                  controller.addresses.refresh();
                }
              },
              label: LK.taluka.tr,
              isRequired: true,
              requiredErrorMessage: LK.talukaRequired.tr,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final areaList = controller.getAddressAreas(addr.taluka);
            return AppFormDropdown<String>(
              value: areaList.contains(addr.area)
                  ? addr.area
                  : null,
              items: areaList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.area = v;
                  controller.addresses.refresh();
                }
              },
              label: LK.area.tr,
              isRequired: true,
              requiredErrorMessage: LK.areaRequired.tr,
            );
          }),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: addr.pincode,
            label: LK.pincode.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            onChanged: (v) => addr.pincode = v,
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: addr.line1,
            label: LK.addressLine1.tr,
            isRequired: true,
            maxLength: 200,
            onChanged: (v) => addr.line1 = v,
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: addr.line2,
            label: LK.addressLine2.tr,
            isRequired: true,
            maxLength: 200,
            onChanged: (v) => addr.line2 = v,
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: addr.landmark,
            label: LK.landmarkLabel.tr,
            maxLength: 200,
            onChanged: (v) => addr.landmark = v,
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: () {
              if (addr.isPrimary) return;
              for (var a in controller.addresses) {
                a.isPrimary = false;
              }
              addr.isPrimary = true;
              controller.addresses.refresh();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: Checkbox(
                      value: addr.isPrimary,
                      onChanged: (v) {
                        final newValue = v ?? false;
                        if (!newValue) return;
                        for (var a in controller.addresses) {
                          a.isPrimary = false;
                        }
                        addr.isPrimary = true;
                        controller.addresses.refresh();
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(LK.isPrimary.tr, style: AppTextStyles.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Obx(
      () => _buildSection(LK.educationTab.tr, Icons.school_outlined, [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.educationList.length} ${LK.educationTab.tr}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            TextButton.icon(
              onPressed: controller.addEducation,
              icon: Icon(Icons.add, size: 18),
              label: Text(LK.addEducation.tr),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (controller.educationList.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    LK.noEducationRecordsYet.tr,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground),
                  ),
                  if (controller.showListErrors.value) ...[
                    SizedBox(height: 4.h),
                    Text(
                      LK.educationRequiredError.tr,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.red),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          ...List.generate(
            controller.educationList.length,
            (index) => _buildEducationItem(index),
          ),
      ]),
    );
  }

  Widget _buildEducationItem(int index) {
    final edu = controller.educationList[index];
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${LK.educationTab.tr} #${index + 1}',
                style: AppTextStyles.labelMedium,
              ),
              IconButton(
                onPressed: () => controller.removeEducation(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.destructive,
                  size: 20,
                ),
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(
            () => AppFormDropdown<String>(
              value: (controller.qualificationList.isEmpty 
                      ? controller.defaultQualifications 
                      : controller.qualificationList).contains(edu.qualification)
                  ? edu.qualification
                  : null,
              items: (controller.qualificationList.isEmpty
                      ? controller.defaultQualifications
                      : controller.qualificationList)
                  .toSet()
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  edu.qualification = v;
                  controller.educationList.refresh();
                }
              },
              label: LK.qualificationLabel.tr,
              isRequired: true,
              requiredErrorMessage: LK.qualificationRequired.tr,
            ),
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: edu.institute,
            label: LK.instituteNameLabel.tr,
            maxLength: 200,
            onChanged: (v) => edu.institute = v,
          ),
          SizedBox(height: 12.h),
          _buildFieldPair(
            AppFormTextField(
              initialValue: edu.passingYear,
              label: LK.passingYearLabel.tr,
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
                      if (dobStr.contains('-') && dobStr.split('-')[0].length == 2) {
                        final parts = dobStr.split('-');
                        dobDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                      } else {
                        dobDate = DateTime.tryParse(dobStr);
                      }
                      
                      if (dobDate != null && year < dobDate.year) {
                        return 'Passing Year cannot be before year of birth';
                      }
                    } catch (_) {}
                  }
                }
                return null;
              },
              onChanged: (v) => edu.passingYear = v,
            ),
            AppFormTextField(
              initialValue: edu.percentage,
              label: LK.percentageLabel.tr,
              hint: '00',
              suffixIcon: Padding(
                padding: EdgeInsets.only(top: 14.h, right: 16.w),
                child: Text('%', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final numVal = double.tryParse(newValue.text);
                  if (numVal != null && numVal > 100) return oldValue;
                  return newValue;
                }),
              ],
              maxLength: 20,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final numVal = double.tryParse(v);
                  if (numVal != null && numVal > 100) {
                    return 'Cannot exceed 100';
                  }
                }
                return null;
              },
              onChanged: (v) => edu.percentage = v,
            ),
          ),
          SizedBox(height: 12.h),
          _buildFieldPair(
            AppFormTextField(
              initialValue: edu.grade,
              label: 'Grade',
              maxLength: 10,
              onChanged: (v) => edu.grade = v,
            ),
            AppFormTextField(
              initialValue: edu.description,
              label: 'Description',
              maxLength: 500,
              onChanged: (v) => edu.description = v,
            ),
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: () {
              if (edu.isHighest) return;
              for (var e in controller.educationList) {
                e.isHighest = false;
              }
              edu.isHighest = true;
              controller.educationList.refresh();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: Checkbox(
                      value: edu.isHighest,
                      onChanged: (v) {
                        final newValue = v ?? false;
                        if (!newValue) return;
                        for (var e in controller.educationList) {
                          e.isHighest = false;
                        }
                        edu.isHighest = true;
                        controller.educationList.refresh();
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(LK.isHighestQualification.tr, style: AppTextStyles.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsLifeSection() {
    return _buildSection(LK.assetsLife.tr, Icons.account_balance_wallet_outlined, [
      _buildFieldPair(
        _buildCheckbox('Own Land', controller.personalInfo.ownLand),
        _buildCheckbox('Own House', controller.personalInfo.ownHouse),
      ),
      _buildFieldPair(
        _buildCheckbox('Two Wheeler', controller.personalInfo.twoWheeler),
        _buildCheckbox('Four Wheeler', controller.personalInfo.fourWheeler),
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.personalInfo.monthlyIncomeCtrl,
        label: LK.monthlyIncomeLabel.tr,
        prefixIcon: Icon(Icons.currency_rupee),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 8,
      ),
    ]);
  }

  Widget _buildWorkHistorySection() {
    return _buildSection(LK.workHistory.tr, Icons.work_outline, [
      _buildFieldPair(
        Obx(() {
          final list = controller.workInfo.occupationTypeList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.occupationType.value)
                ? controller.workInfo.occupationType.value
                : null,
            items: list.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupationType.value = v;
            },
            label: LK.occupationType.tr,
            isRequired: true,
            requiredErrorMessage: LK.occupationTypeRequired.tr,
          );
        }),
        Obx(() {
          final list = controller.workInfo.occupationList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.occupation.value)
                ? controller.workInfo.occupation.value
                : null,
            items: list.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupation.value = v;
            },
            label: LK.occupation.tr,
            isRequired: true,
            requiredErrorMessage: LK.occupationRequired.tr,
          );
        }),
      ),
      SizedBox(height: 12.h),
      Obx(() {
        final list = controller.workInfo.jobPositionList;
        return AppFormDropdown<String>(
          value: list.contains(controller.workInfo.jobPosition.value)
              ? controller.workInfo.jobPosition.value
              : null,
          items: list.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
          onChanged: (v) {
            if (v != null) controller.workInfo.jobPosition.value = v;
          },
          label: LK.jobPositionLabel.tr,
          isRequired: true,
          requiredErrorMessage: LK.jobPositionRequired.tr,
        );
      }),
      SizedBox(height: 12.h),
      _buildFieldPair(
        AppFormTextField(
          controller: controller.otherJobPositionCtrl,
          label: LK.otherJobPositionLabel.tr,
          maxLength: 100,
          onChanged: (v) => controller.workInfo.otherJobPosition.value = v,
        ),
        AppFormTextField(
          controller: controller.otherOccupationCtrl,
          label: LK.otherOccupationLabel.tr,
          maxLength: 100,
          onChanged: (v) => controller.workInfo.otherOccupation.value = v,
        ),
      ),
      SizedBox(height: 12.h),
      _buildFieldPair(
        AppFormTextField(
          controller: controller.companyNameCtrl,
          label: LK.companyNameLabel.tr,
          prefixIcon: Icon(Icons.business),
          maxLength: 100,
          onChanged: (v) => controller.companyName.value = v,
        ),
        AppFormTextField(
          controller: controller.businessNameCtrl,
          label: LK.businessName.tr,
          prefixIcon: Icon(Icons.business_center),
          maxLength: 100,
          onChanged: (v) => controller.businessName.value = v,
        ),
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.occupationDescriptionCtrl,
        label: LK.occupationDescriptionLabel.tr,
        maxLines: 3,
        maxLength: 500,
      ),
      SizedBox(height: 12.h),

      Obx(
        () => AppFormDropdown<String>(
          value: controller.workStateList.contains(controller.workState.value)
                ? controller.workState.value
                : null,
          items: controller.workStateList
              .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workState.value = v;
          },
          label: LK.state.tr,
        ),
      ),
      SizedBox(height: 12.h),
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workDistrictList.contains(controller.workDistrict.value)
                ? controller.workDistrict.value
                : null,
          items: controller.workDistrictList
              .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workDistrict.value = v;
          },
          label: LK.district.tr,
        ),
      ),
      SizedBox(height: 12.h),
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workTalukaList.contains(controller.workTaluka.value)
                ? controller.workTaluka.value
                : null,
          items: controller.workTalukaList
              .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workTaluka.value = v;
          },
          label: LK.taluka.tr,
        ),
      ),
      SizedBox(height: 12.h),
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workAreaList.contains(controller.workArea.value)
                ? controller.workArea.value
                : null,
          items: controller.workAreaList
              .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workArea.value = v;
          },
          label: LK.area.tr,
        ),
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.workAddressLine1Ctrl,
        label: LK.occupationAddressLine1Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        maxLength: 200,
        onChanged: (v) => controller.workAddressLine1.value = v,
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.workAddressLine2Ctrl,
        label: LK.occupationAddressLine2Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        maxLength: 200,
        onChanged: (v) => controller.workAddressLine2.value = v,
      ),
      SizedBox(height: 12.h),
      _buildFieldPair(
        AppFormTextField(
          controller: controller.workLandmarkCtrl,
          label: LK.landmarkLabel.tr,
          prefixIcon: Icon(Icons.location_city_outlined),
          maxLength: 200,
          onChanged: (v) => controller.workLandmark.value = v,
        ),
        AppFormTextField(
          controller: controller.workPincodeCtrl,
          label: LK.pincode.tr,
          prefixIcon: Icon(Icons.pin_drop_outlined),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          onChanged: (v) => controller.workPincode.value = v,
        ),
      ),
    ]);
  }
}
