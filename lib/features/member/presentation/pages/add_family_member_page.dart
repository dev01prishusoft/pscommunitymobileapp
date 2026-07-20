import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/app_formatters.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_date_picker.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_time_picker.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/responsive_containers.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  late final ProfileFormController controller;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(6, (index) => GlobalKey());
  final List<GlobalKey<FormState>> _stepFormKeys = List.generate(
    6,
    (index) => GlobalKey<FormState>(),
  );
  late final PageController _pageController;
  int _currentStep = 0;
  late String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = UniqueKey().toString();
    controller = Get.put(ProfileFormController(), tag: controllerTag);
    controller.markAsAddMode();
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerScrollController.dispose();
    _pageController.dispose();
    Get.delete<ProfileFormController>(tag: controllerTag);
    super.dispose();
  }

  void _animateToStep(int index) {
    if (index < _currentStep) {
      _pageController.jumpToPage(index);
      return;
    }

    for (int i = _currentStep; i < index; i++) {
      final stepFormState = _stepFormKeys[i].currentState;
      if (stepFormState == null) {
        if (i != _currentStep) {
          _pageController.jumpToPage(i);
        }
        return;
      }

      final isValid = stepFormState.validate();
      if (!isValid) {
        if (i != _currentStep) {
          _pageController.jumpToPage(i);
        }
        return;
      }
    }

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.addFamilyMember.tr)),
      body: ResponsiveFormContainer(
        padding: EdgeInsets.zero,
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              _buildStepProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final context = _stepKeys[index].currentContext;
                      if (context != null &&
                          _headerScrollController.hasClients) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: 0.5,
                        );
                      }
                    });
                  },
                  children: [
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[0],
                        child: _buildStepPersonal(),
                      ),
                    ),
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[1],
                        child: _buildStepContact(),
                      ),
                    ),
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[2],
                        child: _buildStepFamily(),
                      ),
                    ),
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[3],
                        child: _buildStepAddresses(),
                      ),
                    ),
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[4],
                        child: _buildStepEducation(),
                      ),
                    ),
                    KeepAliveStepWrapper(
                      child: Form(
                        key: _stepFormKeys[5],
                        child: _buildStepWork(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        _animateToStep(_currentStep - 1);
                      },
                      label: Text(
                        LK.back.tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final isFormLoading = controller.isFormLoading;
                    final isLastStep = _currentStep == 5;
                    final text = isLastStep ? LK.saveChanges.tr : LK.next.tr;

                    return AppPrimaryButton(
                      text: text,
                      height: 50.h,
                      onPressed: isLastStep
                          ? () => controller.submitForm(
                              successMessage: LK.memberAddedSuccessfully.tr,
                            )
                          : () {
                              _animateToStep(_currentStep + 1);
                            },
                      isLoading: isLastStep ? isFormLoading : false,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    return Obx(() {
      final steps = [
        {'title': LK.personal.tr, 'icon': Icons.person_outline},
        {'title': LK.contactVerify.tr, 'icon': Icons.contact_phone_outlined},
        {'title': LK.familyParents.tr, 'icon': Icons.family_restroom_outlined},
        {
          'title': '${LK.addressesTab.tr} (${controller.addresses.length})',
          'icon': Icons.location_on_outlined,
        },
        {
          'title': '${LK.educationTab.tr} (${controller.educationList.length})',
          'icon': Icons.school_outlined,
        },
        {'title': LK.workHistory.tr, 'icon': Icons.work_outline},
      ];

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          controller: _headerScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isActive = _currentStep == index;
              final isCompleted = _currentStep > index;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    key: _stepKeys[index],
                    onTap: () => _animateToStep(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : isCompleted
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : isCompleted
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : AppColors.grey.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : (step['icon'] as IconData),
                            size: 15,
                            color: isActive
                                ? AppColors.white
                                : isCompleted
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            step['title'] as String,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive
                                  ? AppColors.white
                                  : isCompleted
                                  ? AppColors.primary
                                  : AppColors.grey,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 20,
                      height: 1.5,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.2),
                    ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }

  Widget _buildStepPersonal() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: AppSpacing.pM,
      child: Column(
        children: [
          _buildProfilePhotoSection(),
          AppSpacing.vM,
          Container(
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
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hM,
                    Text(LK.personal.tr, style: AppTextStyles.headlineSmall),
                  ],
                ),
                const Divider(height: 24),
                AppFormTextField(
                  controller: controller.firstNameCtrl,
                  label: LK.firstName.tr,
                  isRequired: true,
                  prefixIcon: const Icon(Icons.person),
                  maxLength: 100,
                ),
                AppSpacing.vM,
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.middleNameCtrl,
                    label: LK.middleName.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                    maxLength: 100,
                  ),
                  AppFormTextField(
                    controller: controller.lastNameCtrl,
                    label: LK.lastName.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.person),
                    maxLength: 100,
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.firstNameEnCtrl,
                    label: LK.firstNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.language),
                    maxLength: 100,
                  ),
                  AppFormTextField(
                    controller: controller.lastNameEnCtrl,
                    label: LK.lastNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.language),
                    maxLength: 100,
                  ),
                ),
                _buildFieldPair(
                  AppFormDatePicker(
                    controller: controller.dobCtrl,
                    label: LK.birthDate.tr,
                    lastDate: DateTime.now(),
                  ),
                  AppFormTimePicker(
                    controller: controller.tobCtrl,
                    label: LK.birthTime.tr,
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
                      onChanged: (v) => controller.sign.value = v!,
                      label: LK.sign.tr,
                    ),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.weightCtrl,
                    label: LK.weightKg.tr,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [DecimalAutoInsertFormatter()],
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [DecimalAutoInsertFormatter()],
                    prefixIcon: const Icon(Icons.height),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContact() {
    return SingleChildScrollView(
      padding: AppSpacing.pM,
      child: Column(
        children: [
          Container(
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
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hM,
                    Text(
                      LK.contactVerify.tr,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
                const Divider(height: 24),
                AppFormTextField(
                  controller: controller.mobileCtrl,
                  label: LK.mobileNo.tr,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.phone),
                  maxLength: 10,
                  validator: AppValidators.mobile,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.phone_android),
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emailCtrl,
                  label: LK.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  maxLength: 200,
                  validator: AppValidators.optionalEmail,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.entryPersonMobileCtrl,
                  label: LK.entryPersonMobile.tr,
                  prefixIcon: const Icon(Icons.phone_callback),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emergencyNameCtrl,
                  label: LK.emergencyContactNameLabel.tr,
                  prefixIcon: const Icon(Icons.person_add_alt_1),
                  maxLength: 100,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.emergency_outlined),
                  maxLength: 10,
                  validator: AppValidators.optionalMobile,
                ),
              ],
            ),
          ),
          AppSpacing.vM,
          Container(
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
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hM,
                    Text(LK.socialMedia.tr, style: AppTextStyles.headlineSmall),
                  ],
                ),
                const Divider(height: 24),
                AppFormTextField(
                  controller: controller.facebookCtrl,
                  label: LK.facebook.tr,
                  prefixIcon: const Icon(Icons.facebook),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.whatsappCtrl,
                  label: LK.whatsapp.tr,
                  prefixIcon: const Icon(Icons.chat),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.instagramCtrl,
                  label: LK.instagram.tr,
                  prefixIcon: const Icon(Icons.camera_alt),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.twitterCtrl,
                  label: LK.twitterX.tr,
                  prefixIcon: const Icon(Icons.close),
                  maxLength: 300,
                  validator: AppValidators.url,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepFamily() {
    return SingleChildScrollView(
      padding: AppSpacing.pM,
      child: Container(
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
          children: [
            Row(
              children: [
                Icon(
                  Icons.family_restroom_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.hM,
                Text(LK.familyParents.tr, style: AppTextStyles.headlineSmall),
              ],
            ),
            const Divider(height: 24),
            Obx(
              () => AppFormDropdown<String>(
                value:
                    controller.relationList.contains(controller.relation.value)
                    ? controller.relation.value
                    : null,
                items:
                    (controller.relationList.isEmpty
                            ? controller.defaultRelations
                            : controller.relationList)
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e.tr)),
                        )
                        .toList(),
                onChanged: (v) => controller.relation.value = v!,
                label: LK.relation.tr,
                isRequired: true,
              ),
            ),
            AppSpacing.vM,
            AppFormTextField(
              controller: controller.motherFatherNameCtrl,
              label: LK.motherFatherName.tr,
              prefixIcon: const Icon(Icons.people_outline),
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
                  value:
                      controller.mothersGotraList.contains(
                        controller.mothersGotra.value,
                      )
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
            Obx(() {
              final stateList = controller.workStateList;
              return AppFormDropdown<String>(
                value:
                    stateList.contains(
                      controller.personalInfo.motherState.value,
                    )
                    ? controller.personalInfo.motherState.value
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
              final districtList = controller.getAddressDistricts(
                controller.personalInfo.motherState.value,
              );
              return AppFormDropdown<String>(
                value:
                    districtList.contains(
                      controller.personalInfo.motherDistrict.value,
                    )
                    ? controller.personalInfo.motherDistrict.value
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
              final talukaList = controller.getAddressTalukas(
                controller.personalInfo.motherDistrict.value,
              );
              return AppFormDropdown<String>(
                value:
                    talukaList.contains(
                      controller.personalInfo.motherTaluka.value,
                    )
                    ? controller.personalInfo.motherTaluka.value
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
                    controller.personalInfo.motherTaluka.value = v;
                    controller.personalInfo.motherArea.value = '';
                  }
                },
                label: LK.mothersTaluka.tr,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              final areaList = controller.getAddressAreas(
                controller.personalInfo.motherTaluka.value,
              );
              return AppFormDropdown<String>(
                value:
                    areaList.contains(controller.personalInfo.motherArea.value)
                    ? controller.personalInfo.motherArea.value
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
                    controller.personalInfo.motherArea.value = v;
                  }
                },
                label: LK.mothersArea.tr,
              );
            }),
            AppSpacing.vM,
            Obx(() {
              if (controller.shouldHideLookingForMarriage) {
                return const SizedBox.shrink();
              }
              return _buildCheckbox(
                LK.lookingForMarriage.tr,
                controller.openToMarriage,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepAddresses() {
    return SingleChildScrollView(
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
                  if (controller.showListErrors.value) ...[
                    const SizedBox(height: 8),
                    Text(
                      LK.addressRequiredError.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.addAddress,
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
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  onPressed: controller.addAddress,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(LK.addAddress.tr),
                ),
              ],
            ),
            const SizedBox(height: 8),
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

    final fieldsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.vS,
        Obx(() {
          final typeList = controller.addressTypeList;
          return AppFormDropdown<String>(
            value: typeList.contains(addr.type) ? addr.type : null,
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
            isRequired: true,
            requiredErrorMessage: LK.addressTypeRequired.tr,
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
        AppSpacing.vM,
        Obx(() {
          final districtList = controller.getAddressDistricts(addr.state);
          return AppFormDropdown<String>(
            value: districtList.contains(addr.district) ? addr.district : null,
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
            isRequired: true,
            requiredErrorMessage: LK.districtRequired.tr,
          );
        }),
        AppSpacing.vM,
        Obx(() {
          final talukaList = controller.getAddressTalukas(addr.district);
          return AppFormDropdown<String>(
            value: talukaList.contains(addr.taluka) ? addr.taluka : null,
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
            isRequired: true,
            requiredErrorMessage: LK.talukaRequired.tr,
          );
        }),
        AppSpacing.vM,
        Obx(() {
          final areaList = controller.getAddressAreas(addr.taluka);
          return AppFormDropdown<String>(
            value: areaList.contains(addr.area) ? addr.area : null,
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
            isRequired: true,
            requiredErrorMessage: LK.areaRequired.tr,
          );
        }),
        AppSpacing.vM,
        AppFormTextField(
          initialValue: addr.pincode,
          label: LK.pincode.tr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          onChanged: (v) {
            addr.pincode = v;
            controller.addresses.refresh();
          },
        ),
        AppSpacing.vM,
        AppFormTextField(
          initialValue: addr.line1,
          label: LK.addressLine1.tr,
          isRequired: true,
          maxLength: 300,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 3,
          onChanged: (v) {
            addr.line1 = v;
            controller.addresses.refresh();
          },
        ),
        AppSpacing.vM,
        AppFormTextField(
          initialValue: addr.line2,
          label: LK.addressLine2.tr,
          isRequired: true,
          maxLength: 300,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 3,
          onChanged: (v) {
            addr.line2 = v;
            controller.addresses.refresh();
          },
        ),
        AppSpacing.vM,
        AppFormTextField(
          initialValue: addr.landmark,
          label: LK.landmarkLabel.tr,
          maxLength: 200,
          onChanged: (v) {
            addr.landmark = v;
            controller.addresses.refresh();
          },
        ),
        AppSpacing.vM,
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
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
                AppSpacing.hS,
                Text(LK.isPrimary.tr, style: AppTextStyles.titleSmall),
              ],
            ),
          ),
        ),
      ],
    );

    if (!addr.isPrimary) {
      return Container(
        margin: EdgeInsets.only(bottom: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          boxShadow: [
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
            trailing: IconButton(
              onPressed: () => controller.removeAddress(index),
              icon: Icon(Icons.delete_outline, color: AppColors.red, size: 20),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
                  '${LK.address.tr} #${index + 1} (${LK.primary.tr})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.removeAddress(index),
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

  Widget _buildStepEducation() {
    return SingleChildScrollView(
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
                    LK.noEducationRecordsYet.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  if (controller.showListErrors.value) ...[
                    const SizedBox(height: 8),
                    Text(
                      LK.educationRequiredError.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.addEducation,
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
                  onPressed: controller.addEducation,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(LK.addEducation.tr),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
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
            '${LK.educationTab.tr} #${index + 1}${isHighest ? ' (Highest)' : ''}',
            style: AppTextStyles.labelMedium,
          ),
          trailing: IconButton(
            onPressed: () => controller.removeEducation(index),
            icon: Icon(Icons.delete_outline, color: AppColors.red, size: 20),
          ),
          children: [
            Obx(
              () => AppFormDropdown<String>(
                value:
                    (controller.qualificationList.isEmpty
                            ? controller.defaultQualifications
                            : controller.qualificationList)
                        .contains(edu.qualification)
                    ? edu.qualification
                    : null,
                items:
                    (controller.qualificationList.isEmpty
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
            AppSpacing.vM,
            AppFormTextField(
              initialValue: edu.institute,
              label: LK.instituteNameLabel.tr,
              maxLength: 300,
              onChanged: (v) {
                edu.institute = v;
                controller.educationList.refresh();
              },
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
                      } catch (_) {}
                    }
                  }
                  return null;
                },
                onChanged: (v) {
                  edu.passingYear = v;
                  controller.educationList.refresh();
                },
              ),
              AppFormTextField(
                initialValue: edu.percentage,
                label: LK.percentageLabel.tr,
                hint: '00',
                suffixIcon: Padding(
                  padding: EdgeInsets.only(top: 14.h, right: 16.w),
                  child: Text(
                    '%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
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
                onChanged: (v) {
                  edu.percentage = v;
                  controller.educationList.refresh();
                },
              ),
            ),
            _buildFieldPair(
              AppFormTextField(
                initialValue: edu.grade,
                label: 'Grade',
                maxLength: 10,
                onChanged: (v) {
                  edu.grade = v;
                  controller.educationList.refresh();
                },
              ),
              AppFormTextField(
                initialValue: edu.description,
                label: 'Description',
                maxLength: 500,
                onChanged: (v) {
                  edu.description = v;
                  controller.educationList.refresh();
                },
              ),
            ),
            Column(
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
                                    subtitle:
                                        LK.atLeastOneHighestQualification.tr,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWork() {
    return SingleChildScrollView(
      padding: AppSpacing.pM,
      child: Column(
        children: [
          Container(
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
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hM,
                    Text(LK.assetsLife.tr, style: AppTextStyles.headlineSmall),
                  ],
                ),
                const Divider(height: 24),
                _buildFieldPair(
                  _buildCheckbox(
                    LK.ownLand.tr,
                    controller.personalInfo.ownLand,
                  ),
                  _buildCheckbox(
                    LK.ownHouse.tr,
                    controller.personalInfo.ownHouse,
                  ),
                ),
                _buildFieldPair(
                  _buildCheckbox(
                    LK.twoWheeler.tr,
                    controller.personalInfo.twoWheeler,
                  ),
                  _buildCheckbox(
                    LK.fourWheeler.tr,
                    controller.personalInfo.fourWheeler,
                  ),
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.personalInfo.monthlyIncomeCtrl,
                  label: LK.monthlyIncomeLabel.tr,
                  prefixIcon: const Icon(Icons.currency_rupee),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 8,
                ),
              ],
            ),
          ),
          AppSpacing.vM,
          Container(
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
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.hM,
                    Text(LK.workHistory.tr, style: AppTextStyles.headlineSmall),
                  ],
                ),
                const Divider(height: 24),
                Obx(() {
                  final list = controller.workInfo.occupationTypeList;
                  return AppFormDropdown<String>(
                    value:
                        list.contains(controller.workInfo.occupationType.value)
                        ? controller.workInfo.occupationType.value
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
                      if (v != null)
                        controller.workInfo.occupationType.value = v;
                    },
                    label: LK.occupationType.tr,
                    isRequired: true,
                    requiredErrorMessage: LK.occupationTypeRequired.tr,
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
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.workInfo.occupation.value = v;
                    },
                    label: LK.occupation.tr,
                    isRequired: true,
                    requiredErrorMessage: LK.occupationRequired.tr,
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
                    onChanged: (v) =>
                        controller.workInfo.otherJobPosition.value = v,
                  ),
                  AppFormTextField(
                    controller: controller.otherOccupationCtrl,
                    label: LK.otherOccupationLabel.tr,
                    maxLength: 100,
                    onChanged: (v) =>
                        controller.workInfo.otherOccupation.value = v,
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.companyNameCtrl,
                    label: LK.companyNameLabel.tr,
                    prefixIcon: const Icon(Icons.business),
                    maxLength: 300,
                    onChanged: (v) => controller.companyName.value = v,
                  ),
                  AppFormTextField(
                    controller: controller.businessNameCtrl,
                    label: LK.businessName.tr,
                    prefixIcon: const Icon(Icons.business_center),
                    maxLength: 300,
                    onChanged: (v) => controller.businessName.value = v,
                  ),
                ),
                AppFormTextField(
                  controller: controller.occupationDescriptionCtrl,
                  label: LK.occupationDescriptionLabel.tr,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  maxLength: 500,
                ),
                AppSpacing.vM,
                Obx(
                  () => AppFormDropdown<String>(
                    value:
                        controller.workStateList.contains(
                          controller.workState.value,
                        )
                        ? controller.workState.value
                        : null,
                    items: controller.workStateList
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
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
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
                    value:
                        controller.workTalukaList.contains(
                          controller.workTaluka.value,
                        )
                        ? controller.workTaluka.value
                        : null,
                    items: controller.workTalukaList
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
                      if (v != null) controller.workTaluka.value = v;
                    },
                    label: LK.taluka.tr,
                  ),
                ),
                AppSpacing.vM,
                Obx(
                  () => AppFormDropdown<String>(
                    value:
                        controller.workAreaList.contains(
                          controller.workArea.value,
                        )
                        ? controller.workArea.value
                        : null,
                    items: controller.workAreaList
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
                      if (v != null) controller.workArea.value = v;
                    },
                    label: LK.area.tr,
                  ),
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.workAddressLine1Ctrl,
                  label: LK.occupationAddressLine1Label.tr,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  maxLength: 300,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  onChanged: (v) => controller.workAddressLine1.value = v,
                ),
                AppSpacing.vM,
                AppFormTextField(
                  controller: controller.workAddressLine2Ctrl,
                  label: LK.occupationAddressLine2Label.tr,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  maxLength: 300,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  onChanged: (v) => controller.workAddressLine2.value = v,
                ),
                AppSpacing.vM,
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.workLandmarkCtrl,
                    label: LK.landmarkLabel.tr,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    maxLength: 200,
                    onChanged: (v) => controller.workLandmark.value = v,
                  ),
                  AppFormTextField(
                    controller: controller.workPincodeCtrl,
                    label: LK.pincode.tr,
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    onChanged: (v) => controller.workPincode.value = v,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LK.profilePhoto.tr,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() {
                final file = controller.profileImage.value;
                final isRemoved = controller.personalInfo.isPhotoRemoved.value;
                final hasImage = file != null && !isRemoved;

                if (!hasImage) return const SizedBox.shrink();

                return TextButton.icon(
                  onPressed: controller.removePhoto,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: AppColors.red,
                  ),
                  label: Text(
                    LK.removePhoto.tr,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                    backgroundColor: AppColors.red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ],
          ),
          AppSpacing.vM,
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final file = controller.profileImage.value;
                  return Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      image: file != null
                          ? DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: file == null
                        ? Icon(Icons.person, size: 56, color: AppColors.grey)
                        : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 18,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.white,
                        ),
                        onPressed: controller.pickProfilePhoto,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vM,
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, RxBool value) {
    return Obx(
      () => InkWell(
        onTap: () => value.value = !value.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildFieldPair(Widget child1, Widget child2) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s),
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
}

class KeepAliveStepWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveStepWrapper({super.key, required this.child});

  @override
  State<KeepAliveStepWrapper> createState() => _KeepAliveStepWrapperState();
}

class _KeepAliveStepWrapperState extends State<KeepAliveStepWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
