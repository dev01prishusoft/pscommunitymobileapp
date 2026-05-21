import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileFormController(), tag: UniqueKey().toString());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          LK.addFamilyMember.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildProfilePhotoSection(),
              _buildSection(LK.personal.tr, Icons.person_outline, [
                _buildFieldPair(
                  AppFormTextField(
                    controller: TextEditingController(text: controller.memberNo.value),
                    label: LK.memberNo.tr,
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  AppFormTextField(
                    controller: controller.firstNameCtrl,
                    label: LK.firstName.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.middleNameCtrl,
                    label: LK.middleName.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  AppFormTextField(
                    controller: controller.lastNameCtrl,
                    label: LK.lastName.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.firstNameEnCtrl,
                    label: LK.firstNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.language),
                  ),
                  AppFormTextField(
                    controller: controller.lastNameEnCtrl,
                    label: LK.lastNameEnglish.tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.language),
                  ),
                ),
                _buildFieldPair(
                  AppFormDatePicker(
                    controller: controller.dobCtrl,
                    label: LK.birthDate.tr,
                  ),
                  AppFormTextField(
                    controller: TextEditingController(text: controller.tob.value),
                    label: LK.timeOfBirth.tr,
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                ),
                _buildFieldPair(
                  Obx(() => AppFormDropdown<String>(
                    value: controller.genderList.contains(controller.gender.value) ? controller.gender.value : (controller.genderList.isNotEmpty ? controller.genderList.first : controller.defaultGenders.first),
                    items: (controller.genderList.isEmpty ? controller.defaultGenders : controller.genderList)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.tr))).toList(),
                    onChanged: (v) => controller.gender.value = v!,
                    label: LK.gender.tr,
                  )),
                  Obx(() => AppFormDropdown<String>(
                    value: controller.maritalStatusList.contains(controller.maritalStatus.value) ? controller.maritalStatus.value : (controller.maritalStatusList.isNotEmpty ? controller.maritalStatusList.first : controller.defaultMaritalStatuses.first),
                    items: (controller.maritalStatusList.isEmpty ? controller.defaultMaritalStatuses : controller.maritalStatusList)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.tr))).toList(),
                    onChanged: (v) => controller.maritalStatus.value = v!,
                    label: LK.maritalStatusLabel.tr,
                  )),
                ),
                _buildFieldPair(
                  Obx(() => AppFormDropdown<String>(
                    value: controller.bloodGroupList.contains(controller.bloodGroup.value) ? controller.bloodGroup.value : (controller.bloodGroupList.isNotEmpty ? controller.bloodGroupList.first : controller.defaultBloodGroups.first),
                    items: (controller.bloodGroupList.isEmpty ? controller.defaultBloodGroups : controller.bloodGroupList)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => controller.bloodGroup.value = v!,
                    label: LK.bloodGroup.tr,
                  )),
                  Obx(() => AppFormDropdown<String>(
                    value: controller.signList.contains(controller.sign.value) ? controller.sign.value : (controller.signList.isNotEmpty ? controller.signList.first : controller.defaultSigns.first),
                    items: (controller.signList.isEmpty ? controller.defaultSigns : controller.signList)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => controller.sign.value = v!,
                    label: LK.sign.tr,
                  )),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.weightCtrl,
                    label: LK.weightKg.tr,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  AppFormTextField(
                    controller: controller.heightCtrl,
                    label: LK.heightCm.tr,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.height),
                  ),
                ),
                _buildCheckbox(LK.memberIsActive.tr, controller.isActive),
              ]),
              
              _buildSection(LK.contactVerify.tr, Icons.contact_phone_outlined, [
                AppFormTextField(
                  controller: controller.mobileCtrl,
                  label: LK.mobileNo.tr,
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 12),
                _buildCheckbox(LK.mobileVerified.tr, controller.mobileVerified),
                const SizedBox(height: 12),
                AppFormTextField(
                  controller: controller.secondaryMobileCtrl,
                  label: LK.secondaryMobileLabel.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android),
                ),
                const SizedBox(height: 12),
                AppFormTextField(
                  controller: controller.emailCtrl,
                  label: LK.email.tr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 12),
                _buildFieldPair(
                  AppFormTextField(
                    controller: TextEditingController(text: controller.entryPersonMobile.value),
                    label: LK.entryPersonMobile.tr,
                    prefixIcon: const Icon(Icons.phone_callback),
                  ),
                  AppFormTextField(
                    controller: controller.emergencyNameCtrl,
                    label: LK.emergencyContactNameLabel.tr,
                    prefixIcon: const Icon(Icons.person_add_alt_1),
                  ),
                ),
                AppFormTextField(
                  controller: controller.emergencyNoCtrl,
                  label: LK.emergencyContact.tr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.emergency_outlined),
                ),
              ]),

              _buildSection(LK.familyParents.tr, Icons.family_restroom_outlined, [
                _buildCheckbox(LK.familyHead.tr, controller.isFamilyHead),
                const SizedBox(height: 12),
                Obx(() => AppFormDropdown<String>(
                  value: controller.relationList.contains(controller.relation.value) ? controller.relation.value : (controller.relationList.isNotEmpty ? controller.relationList.first : controller.defaultRelations.first),
                  items: (controller.relationList.isEmpty ? controller.defaultRelations : controller.relationList)
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.tr))).toList(),
                  onChanged: (v) => controller.relation.value = v!,
                  label: LK.role.tr,
                )),
                const SizedBox(height: 12),
                AppFormTextField(
                  controller: TextEditingController(text: controller.motherFatherName.value),
                  label: LK.motherFatherName.tr,
                  prefixIcon: const Icon(Icons.people_outline),
                ),
                const SizedBox(height: 12),
                _buildFieldPair(
                  AppFormDropdown<String>(
                    value: 'Parmar',
                    items: ['Parmar', 'Chauhan', 'Solanki', 'Rathod'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {},
                    label: LK.gotraLabel.tr,
                  ),
                  AppFormDropdown<String>(
                    value: 'Parmar',
                    items: ['Parmar', 'Chauhan', 'Solanki', 'Rathod'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {},
                    label: LK.mothersGotra.tr,
                  ),
                ),
                _buildCheckbox(LK.matrimonial.tr, controller.openToMarriage),
              ]),

              _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.facebookCtrl,
                    label: LK.facebook.tr,
                    prefixIcon: const Icon(Icons.facebook),
                    validator: AppValidators.url,
                  ),
                  AppFormTextField(
                    controller: controller.whatsappCtrl,
                    label: LK.whatsapp.tr,
                    prefixIcon: const Icon(Icons.chat),
                    validator: AppValidators.url,
                  ),
                ),
                _buildFieldPair(
                  AppFormTextField(
                    controller: controller.instagramCtrl,
                    label: LK.instagram.tr,
                    prefixIcon: const Icon(Icons.camera_alt),
                    validator: AppValidators.url,
                  ),
                  AppFormTextField(
                    controller: controller.twitterCtrl,
                    label: LK.twitterX.tr,
                    prefixIcon: const Icon(Icons.close),
                    validator: AppValidators.url,
                  ),
                ),
              ]),

              _buildAddressesSection(),
              _buildEducationSection(),
              _buildWorkHistorySection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppPrimaryButton(
          text: LK.saveChanges.tr,
          onPressed: controller.submitForm,
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 12),
          Expanded(child: child2),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(LK.profilePhoto.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                Obx(() {
                  final file = controller.profileImage.value;
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 4),
                      image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
                    ),
                    child: file == null ? const Icon(Icons.person, size: 60, color: AppColors.mutedForeground) : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
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
                padding: const EdgeInsets.only(top: 16.0),
                child: LinearProgressIndicator(value: controller.uploadProgress.value, color: AppColors.primary),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 16),
          TextButton(
            onPressed: controller.removePhoto,
            child: Text(LK.removePhoto.tr, style: const TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, RxBool value) {
    return Obx(() => InkWell(
      onTap: () => value.value = !value.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              height: 24, width: 24,
              child: Checkbox(value: value.value, onChanged: (v) => value.value = v!, activeColor: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    ));
  }

  Widget _buildAddressesSection() {
    return Obx(() => _buildSection(LK.addressesTab.tr, Icons.location_on_outlined, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${controller.addresses.length} ${LK.addressesTab.tr}', 
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
          TextButton.icon(
            onPressed: controller.addAddress, 
            icon: const Icon(Icons.add, size: 18), 
            label: Text(LK.addAddress.tr),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...List.generate(controller.addresses.length, (index) => _buildAddressItem(index)),
    ]));
  }

  Widget _buildAddressItem(int index) {
    final addr = controller.addresses[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("${LK.address.tr} #${index + 1}", 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              IconButton(
                onPressed: () => controller.removeAddress(index), 
                icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppFormTextField(
            controller: TextEditingController(text: addr.line1),
            label: LK.addressLine1.tr,
            onChanged: (v) => addr.line1 = v,
          ),
          const SizedBox(height: 12),
          AppFormTextField(
            controller: TextEditingController(text: addr.line2),
            label: LK.addressLine2.tr,
            onChanged: (v) => addr.line2 = v,
          ),
          const SizedBox(height: 12),
          _buildFieldPair(
            AppFormTextField(
              controller: TextEditingController(text: addr.landmark),
              label: LK.landmarkLabel.tr,
              onChanged: (v) => addr.landmark = v,
            ),
            AppFormTextField(
              controller: TextEditingController(text: addr.pincode),
              label: LK.pincode.tr,
              onChanged: (v) => addr.pincode = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Obx(() => _buildSection(LK.educationTab.tr, Icons.school_outlined, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${controller.educationList.length} ${LK.educationTab.tr}', 
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
          TextButton.icon(
            onPressed: controller.addEducation, 
            icon: const Icon(Icons.add, size: 18), 
            label: Text(LK.addEducation.tr),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...List.generate(controller.educationList.length, (index) => _buildEducationItem(index)),
    ]));
  }

  Widget _buildEducationItem(int index) {
    final edu = controller.educationList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
              Text("${LK.educationTab.tr} #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              IconButton(
                onPressed: () => controller.removeEducation(index), 
                icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppFormTextField(
            controller: TextEditingController(text: edu.institute),
            label: LK.instituteNameLabel.tr,
            onChanged: (v) => edu.institute = v,
          ),
          const SizedBox(height: 12),
          _buildFieldPair(
            AppFormTextField(
              controller: TextEditingController(text: edu.passingYear),
              label: LK.passingYearLabel.tr,
              onChanged: (v) => edu.passingYear = v,
            ),
            AppFormTextField(
              controller: TextEditingController(text: edu.percentage),
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
        controller: TextEditingController(text: controller.companyName.value),
        label: LK.companyNameLabel.tr,
        prefixIcon: const Icon(Icons.business),
        onChanged: (v) => controller.companyName.value = v,
      ),
      const SizedBox(height: 12),
      _buildFieldPair(
        AppFormTextField(
          controller: TextEditingController(text: controller.businessName.value),
          label: LK.businessName.tr,
          prefixIcon: const Icon(Icons.business_center),
          onChanged: (v) => controller.businessName.value = v,
        ),
        AppFormTextField(
          controller: controller.monthlyIncomeCtrl,
          label: LK.monthlyIncomeLabel.tr,
          prefixIcon: const Icon(Icons.currency_rupee),
        ),
      ),
    ]);
  }
}
