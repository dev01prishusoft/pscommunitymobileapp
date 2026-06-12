import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:pscommunitymobileapp/core/utils/app_formatters.dart';
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
                  controller: controller.firstNameCtrl,
                  label: LK.firstName.tr,
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
                    prefixIcon: Icon(Icons.person),
                    maxLength: 100,
                  ),
                ),
                AppSpacing.vM,
                          _buildFieldPair(
                            AppFormTextField(
                              controller: controller.firstNameEnCtrl,
                              label: LK.firstNameEnglish.tr,
                              prefixIcon: Icon(Icons.language),
                              maxLength: 100,
                            ),
                            AppFormTextField(
                              controller: controller.lastNameEnCtrl,
                              label: LK.lastNameEnglish.tr,
                              prefixIcon: Icon(Icons.language),
                              maxLength: 100,
                            ),
                          ),
                AppSpacing.vM,
                          _buildFieldPair(
                            AppFormDatePicker(
                              controller: controller.dobCtrl,
                              label: LK.birthDate.tr,
                            ),
                            AppFormTimePicker(
                              controller: controller.tobCtrl,
                              label: LK.birthTime.tr,
                            ),
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
                                    DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
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
                                    DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
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
                                if (val != null && val.isNotEmpty) {
                                  if (val.replaceAll('.', '').length > 5) {
                                    return 'Max 5 digits allowed';
                                  }
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
                                if (val != null && val.isNotEmpty) {
                                  if (val.replaceAll('.', '').length > 5) {
                                    return 'Max 5 digits allowed';
                                  }
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
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.phone),
                  maxLength: 10,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.phone_android),
                  maxLength: 10,
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
                  maxLength: 200,
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
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
                  maxLength: 100,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.emergency_outlined),
                  maxLength: 10,
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
                    () => controller.personalInfo.isFamilyHead.value
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16), // AppSpacing.vM
                            child: IgnorePointer(
                              child: AppFormTextField(
                                controller: TextEditingController(
                                  text: controller.personalInfo.relatedToMemberName.value,
                                ),
                                label: '${LK.family.tr} *',
                                readOnly: true,
                              ),
                            ),
                          ),
                  ),
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
                      onChanged: null,
                      label: LK.relation.tr,
                    ),
                  ),
                  AppSpacing.vM,
                  AppFormTextField(
                    controller: controller.motherFatherNameCtrl,
                    label: LK.motherFatherName.tr,
                    prefixIcon: Icon(Icons.people_outline),
                    maxLength: 100,
                  ),
                  AppSpacing.vM,
                  _buildFieldPair(
                    Obx(
                      () => AppFormDropdown<String>(
                        value: controller.gotraList.contains(controller.gotra.value)
                            ? controller.gotra.value
              : null,
                        items: controller.gotraList
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
                          if (v != null) controller.mothersGotra.value = v;
                        },
                        label: LK.mothersGotra.tr,
                      ),
                    ),
                  ),
                  AppSpacing.vM,
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
                  AppSpacing.vM,
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
                  AppSpacing.vM,
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
                  AppSpacing.vM,
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
                          _buildCheckbox(
                            LK.lookingForMarriage.tr,
                            controller.openToMarriage,
                          ),
                ],
              ),

              _buildAssetsLifeSection(),

              _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
                AppFormTextField(
                  controller: controller.facebookCtrl,
                  label: LK.facebook.tr,
                  prefixIcon: Icon(Icons.facebook),
                  maxLength: 300,
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
                  maxLength: 300,
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
                  maxLength: 300,
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
                  maxLength: 300,
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
                onPressed: controller.hasChanges ? () => controller.submitForm(successMessage: LK.editProfileRequestSent.tr) : null,
                isLoading: controller.isFormLoading,
              ),
            ),
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
                  final isRemoved = controller.personalInfo.isPhotoRemoved.value;
                  final showNetworkImage = !isRemoved && profileUrl != null && profileUrl.isNotEmpty;

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
                          : showNetworkImage
                              ? DecorationImage(
                                  image: NetworkImage(profileUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (file == null && !showNetworkImage)
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


          AppSpacing.vM,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.memberNoCtrl,
            builder: (context, value, child) {
              if (value.text.isEmpty) return SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
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
                      child: Icon(
                        Icons.badge_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
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
                        SizedBox(height: 2),
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
    final bool isSameAsFamilyHead = controller.currentMember?.issameAddressasMyFamilyHeadAddress == true;
    final bool isDisabled = !addr.isPrimary || isSameAsFamilyHead;

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
              value: typeList.contains(addr.type)
                  ? addr.type
                  : null,
              items: typeList
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
                  addr.type = v;
                  controller.addresses.refresh();
                }
              },
              label: LK.addressType.tr,
            );
          }),
          AppSpacing.vM,
          Obx(() {
            final stateList = controller.workStateList;
            return AppFormDropdown<String>(
              value: stateList.contains(addr.state)
                  ? addr.state
                  : null,
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
                  controller.addresses.refresh();
                }
              },
              label: LK.area.tr,
            );
          }),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.pincode,
            label: LK.pincode.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            onChanged: (v) => addr.pincode = v,
          ),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.line1,
            label: LK.addressLine1.tr,
            maxLength: 200,
            onChanged: (v) => addr.line1 = v,
          ),
          AppSpacing.vM,
          AppFormTextField( 
            initialValue: addr.line2,
            label: LK.addressLine2.tr,
            maxLength: 200,
            onChanged: (v) => addr.line2 = v,
          ),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: addr.landmark,
            label: LK.landmarkLabel.tr,
            maxLength: 200,
            onChanged: (v) => addr.landmark = v,
          ),
          AppSpacing.vM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Primary',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                          if (states.contains(WidgetState.disabled) && addr.isPrimary) {
                            return AppColors.primary.withValues(alpha: 0.5);
                          }
                          return null;
                        }),
                      ),
                    ),
                    AppSpacing.hS,
                    Text('Primary', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!addr.isPrimary) {
      return Container(
        margin: EdgeInsets.only(bottom: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Theme(
          data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              '${LK.address.tr} #${index + 1}',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            ),
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
            ],
          ),
          fieldsWidget,
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
    final isHighest = edu.isHighest;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isHighest,
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Text(
            '${LK.educationTab.tr} #${index + 1}${isHighest ? ' (Highest)' : ''}',
            style: AppTextStyles.labelMedium,
          ),
          children: [
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
              onChanged: isHighest ? (v) {
                if (v != null) {
                  edu.qualification = v;
                  controller.educationList.refresh();
                }
              } : null,
              label: LK.qualificationLabel.tr,
            ),
          ),
          AppSpacing.vM,
          AppFormTextField(
            initialValue: edu.institute,
            label: LK.instituteNameLabel.tr,
            maxLength: 200,
            readOnly: !isHighest,
            onChanged: isHighest ? (v) {
              edu.institute = v;
              controller.educationList.refresh();
            } : null,
          ),
          AppSpacing.vM,
          _buildFieldPair(
            AppFormTextField(
              initialValue: edu.passingYear,
              label: LK.passingYearLabel.tr,
              hint: 'YYYY',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length != 4) {
                  return 'Must be 4 digits';
                }
                return null;
              },
              readOnly: !isHighest,
              onChanged: isHighest ? (v) {
                edu.passingYear = v;
                controller.educationList.refresh();
              } : null,
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
              readOnly: !isHighest,
              onChanged: isHighest ? (v) {
                edu.percentage = v;
                controller.educationList.refresh();
              } : null,
            ),
          ),
          AppSpacing.vM,
          _buildFieldPair(
            AppFormTextField(
              initialValue: edu.grade,
              label: 'Grade',
              maxLength: 10,
              readOnly: !isHighest,
              onChanged: isHighest ? (v) {
                edu.grade = v;
                controller.educationList.refresh();
              } : null,
            ),
            AppFormTextField(
              initialValue: edu.description,
              label: 'Description',
              maxLength: 500,
              readOnly: !isHighest,
              onChanged: isHighest ? (v) {
                edu.description = v;
                controller.educationList.refresh();
              } : null,
            ),
          ),
          AppSpacing.vM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: LK.markAsHighest.tr,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: edu.isHighest,
                        onChanged: null,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled) && edu.isHighest) {
                            return AppColors.primary.withValues(alpha: 0.5);
                          }
                          return null;
                        }),
                      ),
                    ),
                    AppSpacing.hS,
                    Text(LK.markAsHighest.tr, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
      Obx(() {
        final list = controller.workInfo.occupationTypeList;
        return AppFormDropdown<String>(
          value: list.contains(controller.workInfo.occupationType.value)
              ? controller.workInfo.occupationType.value
              : null,
          items: list
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workInfo.occupationType.value = v;
          },
          label: LK.occupationType.tr,
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workInfo.occupation.value = v;
          },
          label: LK.occupation.tr,
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
            if (v != null) controller.workInfo.jobPosition.value = v;
          },
          label: LK.jobPositionLabel.tr,
        );
      }),
      AppSpacing.vM,
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
      AppSpacing.vM,
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
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.monthlyIncomeCtrl,
        label: LK.monthlyIncomeLabel.tr,
        prefixIcon: Icon(Icons.currency_rupee),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 8,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.occupationDescriptionCtrl,
        label: LK.occupationDescriptionLabel.tr,
        maxLines: 3,
        maxLength: 500,
      ),
      AppSpacing.vM,
      Obx(
        () => AppFormDropdown<String>(
          value: controller.workStateList.contains(controller.workState.value)
              ? controller.workState.value
              : null,
          items: controller.workStateList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
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
          value:
              controller.workDistrictList.contains(
                controller.workDistrict.value,
              )
              ? controller.workDistrict.value
              : null,
          items: controller.workDistrictList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) controller.workArea.value = v;
          },
          label: LK.area.tr,
        ),
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workAddressLine1Ctrl,
        label: LK.occupationAddressLine1Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        maxLength: 200,
        onChanged: (v) => controller.workAddressLine1.value = v,
      ),
      AppSpacing.vM,
      AppFormTextField(
        controller: controller.workAddressLine2Ctrl,
        label: LK.occupationAddressLine2Label.tr,
        prefixIcon: Icon(Icons.location_on_outlined),
        maxLength: 200,
        onChanged: (v) => controller.workAddressLine2.value = v,
      ),
      AppSpacing.vM,
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
