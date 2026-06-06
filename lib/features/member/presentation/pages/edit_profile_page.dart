import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/responsive_containers.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_date_picker.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_time_picker.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';

import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileFormController controller;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileFormController(), tag: UniqueKey().toString());

    _loadMemberData();
  }

  Future<void> _loadMemberData() async {
    try {
      final tokenManager = Get.find<TokenManager>();
      final memberId = tokenManager.memberId;
      if (memberId == null) return;

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getParsed<Member>(
        '/api/v1/member/$memberId',
        fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
      );
      
      final member = response.dataOrNull?.data;
      if (member != null) {
        controller.loadFromMember(member);
      }
    } catch (e) {
      // Ignore or log error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          LK.editProfile.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ResponsiveFormContainer(
              padding: AppSpacing.pM,
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                  children: [
              _buildProfilePhotoSection(),
              _buildSection(LK.personal.tr, Icons.person_outline, initiallyExpanded: true, [
                AppFormTextField(
                  controller: controller.memberNoCtrl,
                  label: LK.memberNo.tr,
                  readOnly: true,
                  prefixIcon: Icon(Icons.numbers),
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.firstNameCtrl,
                  label: LK.firstName.tr,
                  prefixIcon: Icon(Icons.person),
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
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                AppFormDatePicker(
                  controller: controller.dobCtrl,
                  label: LK.birthDate.tr,
                ),
                AppSpacing.vM,
                AppFormTimePicker(
                  controller: controller.tobCtrl,
                  label: LK.birthTime.tr,
                ),
                AppSpacing.vM,
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
                          : null,
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
                          : null,
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
                  readOnly: true,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone),
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_android),
                  validator: (v) {
                    if (v == controller.currentMember?.secondaryMobile) return null;
                    return AppValidators.optionalMobile(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emailCtrl,
                  label: LK.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == controller.currentMember?.emailAddress) return null;
                    return AppValidators.optionalEmail(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.entryPersonMobileCtrl,
                  label: LK.entryPersonMobile.tr,
                  prefixIcon: Icon(Icons.phone_callback),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return AppValidators.optionalMobile(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emergencyNameCtrl,
                  label: LK.emergencyContactNameLabel.tr,
                  prefixIcon: Icon(Icons.person_add_alt_1),
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.emergency_outlined),
                  validator: (v) {
                    if (v == controller.currentMember?.emergencyContactNo) return null;
                    return AppValidators.optionalMobile(v);
                  },
                ),
              ]),

              _buildSection(
                LK.familyParents.tr,
                Icons.family_restroom_outlined,
                [
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.6,
                      child: _buildCheckbox(LK.memberIsFamilyHead.tr, controller.personalInfo.isFamilyHead),
                    ),
                  ),
                  AppSpacing.vM,
                  Obx(
                    () => IgnorePointer(
                      child: AppFormTextField(
                        controller: TextEditingController(text: controller.personalInfo.relatedToMemberName.value),
                        label: '${LK.family.tr} *',
                        readOnly: true,
                      ),
                    ),
                  ),
                  AppSpacing.vM,
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
                      label: LK.role.tr,
                    ),
                  ),
                  AppSpacing.vM,
                  AppFormTextField(
                    controller: controller.motherFatherNameCtrl,
                    label: LK.motherFatherName.tr,
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  AppSpacing.vM,
                  _buildFieldPair(
                    Obx(
                      () => AppFormDropdown<String>(
                        value: controller.gotraList.contains(controller.gotra.value)
                            ? controller.gotra.value
              : null,
                        items: controller.gotraList
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.mothersGotra.value = v;
                        },
                        label: LK.mothersGotra.tr,
                      ),
                    ),
                  ),
                  _buildCheckbox(LK.matrimonial.tr, controller.openToMarriage),
                ],
              ),

              _buildAssetsLifeSection(),

              _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
                AppFormTextField(
                  controller: controller.facebookCtrl,
                  label: LK.facebook.tr,
                  prefixIcon: Icon(Icons.facebook),
                  validator: (v) {
                    if (v == controller.currentMember?.facebookUrl) return null;
                    return AppValidators.url(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.whatsappCtrl,
                  label: LK.whatsapp.tr,
                  prefixIcon: Icon(Icons.chat),
                  validator: (v) {
                    if (v == controller.currentMember?.whatsappUrl) return null;
                    return AppValidators.url(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.instagramCtrl,
                  label: LK.instagram.tr,
                  prefixIcon: Icon(Icons.camera_alt),
                  validator: (v) {
                    if (v == controller.currentMember?.instagramUrl) return null;
                    return AppValidators.url(v);
                  },
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.twitterCtrl,
                  label: LK.twitterX.tr,
                  prefixIcon: Icon(Icons.close),
                  validator: (v) {
                    if (v == controller.currentMember?.twitterUrl) return null;
                    return AppValidators.url(v);
                  },
                ),
              ]),

              _buildAddressesSection(),
              _buildEducationSection(),
              _buildWorkHistorySection(),
              AppSpacing.vXxxl,
            ],
          ),
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
            onPressed: controller.hasChanges ? () => controller.submitForm(successMessage: LK.editProfileRequestSent.tr) : null,
            isLoading: controller.isFormLoading,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children, {bool initiallyExpanded = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              AppSpacing.hM,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Divider(height: 1),
            Padding(
              padding: AppSpacing.pL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldPair(Widget child1, Widget child2) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          AppSpacing.hM,
          Expanded(child: child2),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      margin: AppSpacing.pL,
      padding: AppSpacing.pXl,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(LK.profilePhoto.tr, style: AppTextStyles.headlineSmall),
          AppSpacing.vL,
          Center(
            child: Stack(
              children: [
                Obx(() {
                  final file = controller.profileImage.value;
                  final profileUrl = controller.currentMember?.profilePhotoFullUrl;

                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 4,
                      ),
                      image: file != null
                          ? DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            )
                          : (profileUrl != null && profileUrl.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(profileUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (file == null && (profileUrl == null || profileUrl.isEmpty))
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
                    radius: 20,
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
            if (controller.profileImage.value != null) {
              return Padding(
                padding: EdgeInsets.only(top: AppSpacing.l),
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
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: value.value,
                  onChanged: (v) => value.value = v!,
                  activeColor: AppColors.primary,
                ),
              ),
              AppSpacing.hS,
              Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
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
        AppSpacing.vS,
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
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      padding: AppSpacing.pM,
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
          AppSpacing.vM,
          Obx(() {
            final typeList = controller.contactInfo.addressTypeList;
            return AppFormDropdown<String>(
              value: typeList.contains(addr.type)
                  ? addr.type
                  : null,
              items: typeList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  addr.type = v;
                  controller.addresses.refresh();
                }
              },
              label: LK.addressType.tr,
            );
          }),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.line1,
            label: LK.addressLine1.tr,
            onChanged: (v) => addr.line1 = v,
          ),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.line2,
            label: LK.addressLine2.tr,
            onChanged: (v) => addr.line2 = v,
          ),
          AppSpacing.vM,
          Obx(() {
            final stateList = controller.workStateList;
            return AppFormDropdown<String>(
              value: stateList.contains(addr.state)
                  ? addr.state
                  : null,
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
          AppSpacing.vM,
          Obx(() {
            final districtList = controller.getAddressDistricts(addr.state);
            return AppFormDropdown<String>(
              value: districtList.contains(addr.district)
                  ? addr.district
                  : null,
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
          AppSpacing.vM,
          Obx(() {
            final talukaList = controller.getAddressTalukas(addr.district);
            return AppFormDropdown<String>(
              value: talukaList.contains(addr.taluka)
                  ? addr.taluka
                  : null,
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
          AppSpacing.vM,
          Obx(() {
            final areaList = controller.getAddressAreas(addr.taluka);
            return AppFormDropdown<String>(
              value: areaList.contains(addr.area)
                  ? addr.area
                  : null,
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
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.landmark,
            label: LK.landmarkLabel.tr,
            onChanged: (v) => addr.landmark = v,
          ),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.pincode,
            label: LK.pincode.tr,
            onChanged: (v) => addr.pincode = v,
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
        AppSpacing.vS,
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
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      padding: AppSpacing.pM,
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
          AppSpacing.vM,
          Obx(
            () => AppFormDropdown<String>(
              value: controller.qualificationList.contains(edu.qualification)
                  ? edu.qualification
                  : null,
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
          AppSpacing.vM,
          AppFormTextField(
            initialValue: edu.institute,
            label: LK.instituteNameLabel.tr,
            onChanged: (v) => edu.institute = v,
          ),
          AppSpacing.vM,
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
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.monthlyIncomeCtrl,
        label: LK.monthlyIncomeLabel.tr,
        prefixIcon: Icon(Icons.currency_rupee),
        keyboardType: TextInputType.number,
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
            items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupationType.value = v;
            },
            label: LK.occupationType.tr,
          );
        }),
        Obx(() {
          final list = controller.workInfo.occupationList;
          return AppFormDropdown<String>(
            value: list.contains(controller.workInfo.occupation.value)
                ? controller.workInfo.occupation.value
                : null,
            items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) controller.workInfo.occupation.value = v;
            },
            label: LK.occupation.tr,
          );
        }),
      ),
      SizedBox(height: 12),
      Obx(() {
        final list = controller.workInfo.jobPositionList;
        return AppFormDropdown<String>(
          value: list.contains(controller.workInfo.jobPosition.value)
              ? controller.workInfo.jobPosition.value
              : null,
          items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) controller.workInfo.jobPosition.value = v;
          },
          label: LK.jobPositionLabel.tr,
        );
      }),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.companyNameCtrl,
        label: LK.companyNameLabel.tr,
        prefixIcon: Icon(Icons.business),
        onChanged: (v) => controller.companyName.value = v,
      ),
      AppSpacing.vM,
      _buildFieldPair(
        AppFormTextField(
          controller: controller.otherJobPositionCtrl,
          label: LK.otherJobPositionLabel.tr,
          onChanged: (v) => controller.workInfo.otherJobPosition.value = v,
        ),
        AppFormTextField(
          controller: controller.otherJobPositionEnglishCtrl,
          label: 'Other Job Position (English)',
          onChanged: (v) => controller.workInfo.otherJobPositionEnglish.value = v,
        ),
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.otherOccupationCtrl,
        label: LK.otherOccupationLabel.tr,
        onChanged: (v) => controller.workInfo.otherOccupation.value = v,
      ),
      AppSpacing.vM,
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.businessNameCtrl,
        label: LK.businessName.tr,
        prefixIcon: Icon(Icons.business_center),
        onChanged: (v) => controller.businessName.value = v,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workAddressLine1Ctrl,
        label: LK.occupationAddressLine1Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        onChanged: (v) => controller.workAddressLine1.value = v,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workAddressLine2Ctrl,
        label: LK.occupationAddressLine2Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        onChanged: (v) => controller.workAddressLine2.value = v,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workLandmarkCtrl,
        label: LK.landmarkLabel.tr,
        prefixIcon: Icon(Icons.location_city_outlined),
        onChanged: (v) => controller.workLandmark.value = v,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workPincodeCtrl,
        label: LK.pincode.tr,
        prefixIcon: Icon(Icons.pin_drop_outlined),
        keyboardType: TextInputType.number,
        onChanged: (v) => controller.workPincode.value = v,
      ),
      AppSpacing.vM,
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workStateList.contains(controller.workState.value)
              ? controller.workState.value
              : null,
          items: controller.workStateList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workState.value = v;
          },
          label: LK.state.tr,
        ),
      ),
      AppSpacing.vM,
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workDistrictList.contains(controller.workDistrict.value)
              ? controller.workDistrict.value
              : null,
          items: controller.workDistrictList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workDistrict.value = v;
          },
          label: LK.district.tr,
        ),
      ),
      AppSpacing.vM,
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workTalukaList.contains(controller.workTaluka.value)
              ? controller.workTaluka.value
              : null,
          items: controller.workTalukaList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workTaluka.value = v;
          },
          label: LK.taluka.tr,
        ),
      ),
      AppSpacing.vM,
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workAreaList.contains(controller.workArea.value)
              ? controller.workArea.value
              : null,
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
