import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_date_picker.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';

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
      appBar: AppBar(
        title: Text(
          LK.addFamilyMember.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildProfilePhotoSection(),
              _buildSection(LK.personal.tr, Icons.person_outline, [
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.memberNoCtrl,
                    label: LK.memberNo.tr,
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  AppFormTextField(
                    controller: controller.firstNameCtrl,
                    label: LK.firstName.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.middleNameCtrl,
                    label: LK.middleName.tr,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  AppFormTextField(
                    controller: controller.lastNameCtrl,
                    label: LK.lastName.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.firstNameEnCtrl,
                    label: LK.firstNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.language),
                  ),
                  AppFormTextField(
                    controller: controller.lastNameEnCtrl,
                    label: LK.lastNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
                AppFormDatePicker(
                  controller: controller.dobCtrl,
                  label: LK.birthDate.tr,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.tobCtrl,
                  label: LK.timeOfBirth.tr,
                  prefixIcon: Icon(Icons.access_time),
                ),
                SizedBox(height: 12.h),
                _buildFieldPair(
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.genderList.contains(
                            controller.gender.value,
                          )
                          ? controller.gender.value
                          : (controller.genderList.isNotEmpty
                                ? controller.genderList.first
                                : controller.defaultGenders.first),
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
                    ),
                  ),
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.maritalStatusList.contains(
                            controller.maritalStatus.value,
                          )
                          ? controller.maritalStatus.value
                          : (controller.maritalStatusList.isNotEmpty
                                ? controller.maritalStatusList.first
                                : controller.defaultMaritalStatuses.first),
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
                      onChanged: (v) => controller.maritalStatus.value = v!,
                      label: LK.maritalStatusLabel.tr,
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
                          : (controller.bloodGroupList.isNotEmpty
                                ? controller.bloodGroupList.first
                                : controller.defaultBloodGroups.first),
                      items:
                          (controller.bloodGroupList.isEmpty
                                  ? controller.defaultBloodGroups
                                  : controller.bloodGroupList)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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
                          : (controller.signList.isNotEmpty
                                ? controller.signList.first
                                : controller.defaultSigns.first),
                      items:
                          (controller.signList.isEmpty
                                  ? controller.defaultSigns
                                  : controller.signList)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  AppFormTextField(
                    controller: controller.heightCtrl,
                    label: LK.heightCm.tr,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
              ]),

              _buildSection(LK.contactVerify.tr, Icons.contact_phone_outlined, [
                AppFormTextField(
                  controller: controller.mobileCtrl,
                  label: LK.mobileNo.tr,
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone),
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_android),
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emailCtrl,
                  label: LK.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                  validator: AppValidators.email,
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.entryPersonMobileCtrl,
                  label: LK.entryPersonMobile.tr,
                  prefixIcon: Icon(Icons.phone_callback),
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emergencyNameCtrl,
                  label: LK.emergencyContactNameLabel.tr,
                  prefixIcon: Icon(Icons.person_add_alt_1),
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.emergency_outlined),
                ),
              ]),

              _buildSection(
                LK.familyParents.tr,
                Icons.family_restroom_outlined,
                [
                  _buildCheckbox(LK.familyHead.tr, controller.isFamilyHead),
                  SizedBox(height: 12.h),
                  Obx(
                    () => AppFormDropdown<String>(
                      value:
                          controller.relationList.contains(
                            controller.relation.value,
                          )
                          ? controller.relation.value
                          : (controller.relationList.isNotEmpty
                                ? controller.relationList.first
                                : controller.defaultRelations.first),
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
                      label: LK.role.tr,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppFormTextField(
                    controller: controller.motherFatherNameCtrl,
                    label: LK.motherFatherName.tr,
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldPair(
                    AppFormDropdown<String>(
                      value: 'Parmar',
                      items: ['Parmar', 'Chauhan', 'Solanki', 'Rathod']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {},
                      label: LK.gotraLabel.tr,
                    ),
                    AppFormDropdown<String>(
                      value: 'Parmar',
                      items: ['Parmar', 'Chauhan', 'Solanki', 'Rathod']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {},
                      label: LK.mothersGotra.tr,
                    ),
                  ),
                  _buildCheckbox(LK.matrimonial.tr, controller.openToMarriage),
                ],
              ),

              _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.facebookCtrl,
                    label: LK.facebook.tr,
                    prefixIcon: Icon(Icons.facebook),
                    validator: AppValidators.url,
                  ),
                  AppFormTextField(
                    controller: controller.whatsappCtrl,
                    label: LK.whatsapp.tr,
                    prefixIcon: Icon(Icons.chat),
                    validator: AppValidators.url,
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.instagramCtrl,
                    label: LK.instagram.tr,
                    prefixIcon: Icon(Icons.camera_alt),
                    validator: AppValidators.url,
                  ),
                  AppFormTextField(
                    controller: controller.twitterCtrl,
                    label: LK.twitterX.tr,
                    prefixIcon: Icon(Icons.close),
                    validator: AppValidators.url,
                  ),
                ),
              ]),

              _buildAddressesSection(),
              _buildEducationSection(),
              _buildWorkHistorySection(),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.0),
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
        child: Obx(
          () => AppPrimaryButton(
            text: LK.saveChanges.tr,
            onPressed: () => controller.submitForm(successMessage: 'Member Added Successfully'),
            isLoading: controller.isFormLoading,
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
          Obx(() {
            if (controller.uploadProgress.value > 0.0) {
              return Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: LinearProgressIndicator(
                  value: controller.uploadProgress.value,
                  color: AppColors.primary,
                ),
              );
            }
            return SizedBox.shrink();
          }),
          Obx(() {
            if (controller.profileImage.value != null) {
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: TextButton(
                  onPressed: controller.removePhoto,
                  child: Text(
                    LK.removePhoto.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.destructive,
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
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
          AppFormTextField(
            initialValue: addr.line1,
            label: LK.addressLine1.tr,
            onChanged: (v) => addr.line1 = v,
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: addr.line2,
            label: LK.addressLine2.tr,
            onChanged: (v) => addr.line2 = v,
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final stateList = controller.workStateList;
            return AppFormDropdown<String>(
              value: stateList.contains(addr.state)
                  ? addr.state
                  : (stateList.isNotEmpty ? stateList.first : null),
              items: stateList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final districtList = controller.getAddressDistricts(addr.state);
            return AppFormDropdown<String>(
              value: districtList.contains(addr.district)
                  ? addr.district
                  : (districtList.isNotEmpty ? districtList.first : null),
              items: districtList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final talukaList = controller.getAddressTalukas(addr.district);
            return AppFormDropdown<String>(
              value: talukaList.contains(addr.taluka)
                  ? addr.taluka
                  : (talukaList.isNotEmpty ? talukaList.first : null),
              items: talukaList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.taluka = v;
                  addr.area = '';
                  controller.addresses.refresh();
                }
              },
              label: LK.taluka.tr,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final areaList = controller.getAddressAreas(addr.taluka);
            return AppFormDropdown<String>(
              value: areaList.contains(addr.area)
                  ? addr.area
                  : (areaList.isNotEmpty ? areaList.first : null),
              items: areaList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.area = v;
                  controller.addresses.refresh();
                }
              },
              label: LK.area.tr,
            );
          }),
          SizedBox(height: 12.h),
          _buildFieldPair(
            AppFormTextField(
              initialValue: addr.landmark,
              label: LK.landmarkLabel.tr,
              onChanged: (v) => addr.landmark = v,
            ),
            AppFormTextField(
              initialValue: addr.pincode,
              label: LK.pincode.tr,
              onChanged: (v) => addr.pincode = v,
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
              value: controller.qualificationList.contains(edu.qualification)
                  ? edu.qualification
                  : (controller.qualificationList.isNotEmpty
                      ? controller.qualificationList.first
                      : controller.defaultQualifications.first),
              items: (controller.qualificationList.isEmpty
                      ? controller.defaultQualifications
                      : controller.qualificationList)
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  edu.qualification = v;
                  controller.educationList.refresh();
                }
              },
              label: LK.qualificationLabel.tr,
            ),
          ),
          SizedBox(height: 12.h),
          AppFormTextField(
            initialValue: edu.institute,
            label: LK.instituteNameLabel.tr,
            onChanged: (v) => edu.institute = v,
          ),
          SizedBox(height: 12.h),
          _buildFieldPair(
            AppFormTextField(
              initialValue: edu.passingYear,
              label: LK.passingYearLabel.tr,
              onChanged: (v) => edu.passingYear = v,
            ),
            AppFormTextField(
              initialValue: edu.percentage,
              label: LK.percentageLabel.tr,
              onChanged: (v) => edu.percentage = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHistorySection() {
    return _buildSection(LK.workHistory.tr, Icons.work_outline, [
      AppFormTextField(
        controller: controller.companyNameCtrl,
        label: LK.companyNameLabel.tr,
        prefixIcon: Icon(Icons.business),
        onChanged: (v) => controller.companyName.value = v,
      ),
      SizedBox(height: 12.h),
      _buildFieldPair(
        AppFormTextField(
          controller: controller.businessNameCtrl,
          label: LK.businessName.tr,
          prefixIcon: Icon(Icons.business_center),
          onChanged: (v) => controller.businessName.value = v,
        ),
        AppFormTextField(
          controller: controller.monthlyIncomeCtrl,
          label: LK.monthlyIncomeLabel.tr,
          prefixIcon: Icon(Icons.currency_rupee),
        ),
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.jobPositionCtrl,
        label: LK.jobPositionLabel.tr,
        prefixIcon: Icon(Icons.description_outlined),
        onChanged: (v) => controller.jobPosition.value = v,
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.workAddressLine1Ctrl,
        label: LK.occupationAddressLine1Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        onChanged: (v) => controller.workAddressLine1.value = v,
      ),
      SizedBox(height: 12.h),
      AppFormTextField(
        controller: controller.workAddressLine2Ctrl,
        label: LK.occupationAddressLine2Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        onChanged: (v) => controller.workAddressLine2.value = v,
      ),
      SizedBox(height: 12.h),
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workStateList.contains(controller.workState.value)
              ? controller.workState.value
              : (controller.workStateList.isNotEmpty
                  ? controller.workStateList.first
                  : null),
          items: controller.workStateList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
              : (controller.workDistrictList.isNotEmpty
                  ? controller.workDistrictList.first
                  : null),
          items: controller.workDistrictList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
              : (controller.workTalukaList.isNotEmpty
                  ? controller.workTalukaList.first
                  : null),
          items: controller.workTalukaList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
              : (controller.workAreaList.isNotEmpty
                  ? controller.workAreaList.first
                  : null),
          items: controller.workAreaList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workArea.value = v;
          },
          label: LK.area.tr,
        ),
      ),
    ]);
  }
}
