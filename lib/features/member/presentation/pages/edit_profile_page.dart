import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileFormController controller = Get.put(ProfileFormController());
  final ScrollController _scrollController = ScrollController();

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
          LK.editProfile.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            _buildProfilePhotoSection(),
            _buildSection(LK.personal.tr, Icons.person_outline, [
              _buildFieldPair(
                _buildTextField(LK.memberNo.tr, controller.memberNo, Icons.numbers, readOnly: true),
                _buildTextField('${LK.firstName.tr} *', controller.firstName, Icons.person),
              ),
              _buildFieldPair(
                _buildTextField(LK.middleName.tr, controller.middleName, Icons.person_outline),
                _buildTextField('${LK.lastName.tr} *', controller.lastName, Icons.person),
              ),
              _buildFieldPair(
                _buildTextField('${LK.firstNameEnglish.tr} *', controller.firstNameEn, Icons.language),
                _buildTextField('${LK.lastNameEnglish.tr} *', controller.lastNameEn, Icons.language),
              ),
              _buildFieldPair(
                _buildDatePicker(LK.birthDate.tr, controller.dob),
                _buildTimePicker(LK.timeOfBirth.tr, controller.tob),
              ),
              _buildFieldPair(
                Obx(() => _buildDropdown(LK.gender.tr, controller.gender, controller.genderList.isEmpty ? controller.defaultGenders : controller.genderList, translateItems: true)),
                Obx(() => _buildDropdown(LK.maritalStatusLabel.tr, controller.maritalStatus, controller.maritalStatusList.isEmpty ? controller.defaultMaritalStatuses : controller.maritalStatusList, translateItems: true)),
              ),
              _buildFieldPair(
                Obx(() => _buildDropdown(LK.bloodGroup.tr, controller.bloodGroup, controller.bloodGroupList.isEmpty ? controller.defaultBloodGroups : controller.bloodGroupList, translateItems: false)),
                Obx(() => _buildDropdown(LK.sign.tr, controller.sign, controller.signList.isEmpty ? controller.defaultSigns : controller.signList, translateItems: false)),
              ),
              _buildFieldPair(
                _buildTextField(LK.weightKg.tr, controller.weight, Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                _buildTextField(LK.heightCm.tr, controller.height, Icons.height, keyboardType: TextInputType.number),
              ),
              _buildCheckbox(LK.memberIsActive.tr, controller.isActive),
            ]),

            _buildSection(LK.contactVerify.tr, Icons.contact_phone_outlined, [
              _buildTextField('${LK.mobileNo.tr} *', controller.mobileNo, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildCheckboxField(LK.mobileVerified.tr, controller.mobileVerified, LK.notVerified.tr),
              const SizedBox(height: 12),
              _buildTextField(LK.secondaryMobileLabel.tr, controller.secondaryMobile, Icons.phone_android),
              const SizedBox(height: 12),
              _buildTextField(LK.email.tr, controller.email, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildFieldPair(
                _buildTextField(LK.entryPersonMobile.tr, controller.entryPersonMobile, Icons.phone_callback),
                _buildTextField(LK.emergencyContactNameLabel.tr, controller.emergencyContactName, Icons.person_add_alt_1),
              ),
              _buildTextField(LK.emergencyContact.tr, controller.emergencyContactNo, Icons.emergency_outlined),
            ]),

            _buildSection(LK.familyParents.tr, Icons.family_restroom_outlined, [
              _buildCheckboxField(LK.familyHead.tr, controller.isFamilyHead, LK.memberIsFamilyHead.tr),
              const SizedBox(height: 12),
              Obx(() => _buildDropdown(LK.role.tr, controller.relation, controller.relationList.isEmpty ? controller.defaultRelations : controller.relationList, translateItems: true)),
              const SizedBox(height: 12),
              _buildTextField(LK.motherFatherName.tr, controller.motherFatherName, Icons.people_outline),
              _buildFieldPair(
                _buildDropdown(LK.gotraLabel.tr, controller.gotra, ['Parmar', 'Chauhan', 'Solanki', 'Rathod']),
                _buildDropdown(LK.mothersGotra.tr, controller.mothersGotra, ['Parmar', 'Chauhan', 'Solanki', 'Rathod']),
              ),
              _buildCheckboxField(LK.matrimonial.tr, controller.openToMarriage, LK.openToMarriageProposals.tr),
            ]),

            _buildSection(LK.assetsLife.tr, Icons.home_work_outlined, [
              _buildFieldPair(
                _buildCheckboxField(LK.ownLand.tr, controller.ownLand, LK.yes.tr),
                _buildCheckboxField(LK.ownHouse.tr, controller.ownHouse, LK.yes.tr),
              ),
              _buildFieldPair(
                _buildCheckboxField(LK.twoWheeler.tr, controller.twoWheeler, LK.yes.tr),
                _buildCheckboxField(LK.fourWheeler.tr, controller.fourWheeler, LK.yes.tr),
              ),
              _buildTextField(LK.monthlyIncomeLabel.tr, controller.monthlyIncome, Icons.currency_rupee, keyboardType: TextInputType.number),
            ]),

            _buildSection(LK.socialMedia.tr, Icons.share_outlined, [
              _buildFieldPair(
                _buildTextField(LK.facebook.tr, controller.facebook, Icons.facebook),
                _buildTextField(LK.whatsapp.tr, controller.whatsapp, Icons.chat),
              ),
              _buildFieldPair(
                _buildTextField(LK.instagram.tr, controller.instagram, Icons.camera_alt),
                _buildTextField(LK.twitterX.tr, controller.twitter, Icons.close),
              ),
            ]),

            _buildAddressesSection(),
            _buildEducationSection(),
            _buildWorkHistorySection(),
            const SizedBox(height: 32),
          ],
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
          onPressed: () {
            Get.back<void>();
            Get.snackbar(LK.success.tr, LK.successUpdate.tr, 
              backgroundColor: AppColors.success, colorText: Colors.white);
          },
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
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 4),
                  ),
                  child: const Icon(Icons.person, size: 60, color: AppColors.mutedForeground),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text(LK.removePhoto.tr, style: const TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
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
          Obx(() => _buildDropdownSimple(LK.addressType.tr, addr.type, controller.addressTypeList.isEmpty ? controller.defaultAddressTypes : controller.addressTypeList, (v) => addr.type = v!, translateItems: false)),
          const SizedBox(height: 12),
          _buildFieldPair(
            _buildDropdownSimple(LK.stateLabel.tr, addr.state, ['Gujarat', 'Maharashtra', 'Rajasthan'], (v) => addr.state = v!),
            _buildDropdownSimple(LK.districtLabel.tr, addr.district, ['Ahmedabad', 'Surat', 'Rajkot'], (v) => addr.district = v!),
          ),
          _buildFieldPair(
            _buildDropdownSimple(LK.talukaLabel.tr, addr.taluka, ['Ahmedabad City', 'Barwala', 'Dhandhuka'], (v) => addr.taluka = v!),
            _buildDropdownSimple(LK.areaLabel.tr, addr.area, ['Bapunagar', 'Nikol', 'Odhav'], (v) => addr.area = v!),
          ),
          _buildTextFieldSimple(LK.pincode.tr, addr.pincode, (v) => addr.pincode = v),
          const SizedBox(height: 12),
          _buildTextFieldSimple(LK.addressLine1.tr, addr.line1, (v) => addr.line1 = v),
          const SizedBox(height: 12),
          _buildTextFieldSimple(LK.addressLine2.tr, addr.line2, (v) => addr.line2 = v),
          const SizedBox(height: 12),
          _buildFieldPair(
            _buildTextFieldSimple(LK.landmarkLabel.tr, addr.landmark, (v) => addr.landmark = v),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildCheckboxSimple(LK.primaryAddress.tr, addr.isPrimary, (v) => setState(() => addr.isPrimary = v!)),
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
          Obx(() => _buildDropdownSimple(LK.qualificationLabel.tr, edu.qualification, controller.qualificationList.isEmpty ? controller.defaultQualifications : controller.qualificationList, (v) => edu.qualification = v!, translateItems: false)),
          const SizedBox(height: 12),
          _buildFieldPair(
            _buildTextFieldSimple(LK.instituteNameLabel.tr, edu.institute, (v) => edu.institute = v),
            _buildTextFieldSimple(LK.passingYearLabel.tr, edu.passingYear, (v) => edu.passingYear = v),
          ),
          _buildFieldPair(
            _buildTextFieldSimple(LK.percentageLabel.tr, edu.percentage, (v) => edu.percentage = v),
            _buildTextFieldSimple(LK.gradeLabel.tr, edu.grade, (v) => edu.grade = v),
          ),
          _buildTextFieldSimple(LK.descriptionLabel.tr, edu.description, (v) => edu.description = v),
          const SizedBox(height: 8),
          _buildCheckboxSimple(LK.markAsHighest.tr, edu.isHighest, (bool? v) => setState(() => edu.isHighest = v!)),
        ],
      ),
    );
  }

  Widget _buildWorkHistorySection() {
    return _buildSection(LK.workHistory.tr, Icons.work_outline, [
      Obx(() => _buildDropdown(LK.occupationTypeLabel.tr, controller.occupationType, controller.occupationTypeList.isEmpty ? controller.defaultOccupationTypes : controller.occupationTypeList, translateItems: false)),
      const SizedBox(height: 12),
      _buildFieldPair(
        _buildDropdown(LK.occupationLabel.tr, controller.occupation, ['Dairy Farming', 'Software', 'Real Estate']),
        _buildDropdown(LK.role.tr, controller.jobPosition, ['Senior Developer', 'Manager', 'Owner']),
      ),
      _buildFieldPair(
        _buildTextField(LK.otherJobPositionLabel.tr, controller.otherJobPosition, Icons.work_outline),
        _buildTextField(LK.otherOccupationLabel.tr, controller.otherOccupation, Icons.work_outline),
      ),
      _buildTextField(LK.companyNameLabel.tr, controller.companyName, Icons.business),
      const SizedBox(height: 12),
      _buildFieldPair(
        _buildTextField(LK.businessName.tr, controller.businessName, Icons.business_center),
        _buildTextField(LK.monthlyIncomeLabel.tr, controller.workMonthlyIncome, Icons.currency_rupee),
      ),
      _buildTextField(LK.descriptionLabel.tr, controller.occupationDescription, Icons.description_outlined),
      const SizedBox(height: 12),
      _buildDropdown(LK.stateLabel.tr, controller.workState, ['Gujarat', 'Maharashtra']),
      const SizedBox(height: 12),
      _buildFieldPair(
        _buildDropdown(LK.districtLabel.tr, controller.workDistrict, ['Ahmedabad', 'Surat']),
        _buildDropdown(LK.talukaLabel.tr, controller.workTaluka, ['Barwala', 'Dhandhuka']),
      ),
      _buildDropdown(LK.areaLabel.tr, controller.workArea, ['Bapunagar', 'Nikol']),
      const SizedBox(height: 12),
      _buildTextField(LK.occupationAddressLine1Label.tr, controller.workAddressLine1, Icons.location_on_outlined),
      _buildTextField(LK.occupationAddressLine2Label.tr, controller.workAddressLine2, Icons.location_on_outlined),
    ]);
  }

  // --- Helper Widgets ---

  Widget _buildTextField(String label, RxString value, IconData icon, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    final textController = TextEditingController(text: value.value);
    textController.addListener(() => value.value = textController.text);
    return AppTextField(
      controller: textController,
      hint: '', label: label, icon: icon, readOnly: readOnly, keyboardType: keyboardType,
    );
  }

  Widget _buildTextFieldSimple(String label, String initialValue, void Function(String) onChanged) {
    final textController = TextEditingController(text: initialValue);
    textController.addListener(() => onChanged(textController.text));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
        const SizedBox(height: 4),
        TextField(
          controller: textController,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, RxString value) {
    final textController = TextEditingController(text: value.value);
    return AppTextField(
      controller: textController,
      hint: '', label: label, icon: Icons.calendar_today_outlined, readOnly: true,
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
        if (date != null) {
          value.value = "${date.day}-${date.month}-${date.year}";
          textController.text = value.value;
        }
      },
    );
  }

  Widget _buildTimePicker(String label, RxString value) {
    final textController = TextEditingController(text: value.value);
    return AppTextField(
      controller: textController,
      hint: '', label: label, icon: Icons.access_time, readOnly: true,
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          value.value = time.format(context);
          textController.text = value.value;
        }
      },
    );
  }

  Widget _buildDropdown(String label, RxString value, List<String> items, {bool translateItems = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value.value) ? value.value : items.first,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(translateItems ? e.tr : e, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) => value.value = v!,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDropdownSimple(String label, String value, List<String> items, void Function(String?) onChanged, {bool translateItems = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              isDense: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(translateItems ? e.tr : e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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

  Widget _buildCheckboxField(String label, RxBool value, String checkboxText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              SizedBox(
                height: 24, width: 24,
                child: Checkbox(value: value.value, onChanged: (v) => value.value = v!, activeColor: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(checkboxText, style: const TextStyle(fontSize: 13))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCheckboxSimple(String label, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        SizedBox(
          height: 24, width: 24,
          child: Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
