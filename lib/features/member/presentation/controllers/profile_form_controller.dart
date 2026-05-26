import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/address_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/education_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/utils/form_state_mixin.dart';

class ProfileFormController extends GetxController with FormStateMixin {
  Member? _currentMember;
  final formKey = GlobalKey<FormState>();
  final defaultGenders = ['Male', 'Female', 'Other'];
  final defaultMaritalStatuses = ['Married', 'Unmarried', 'Widow', 'Divorced'];
  final defaultBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final defaultRelations = [
    'Self',
    'Wife',
    'Son',
    'Daughter',
    'Father',
    'Mother',
  ];
  final defaultAddressTypes = ['Home', 'Office', 'Other'];
  final defaultQualifications = ['Graduate', 'HSC', 'SSC', 'Post Graduate'];
  final defaultOccupationTypes = [
    'Agriculture',
    'Business',
    'Job',
    'Profession',
  ];
  final defaultSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];
  final genderList = <String>[].obs;
  final maritalStatusList = <String>[].obs;
  final bloodGroupList = <String>[].obs;
  final relationList = <String>[].obs;
  final addressTypeList = <String>[].obs;
  final qualificationList = <String>[].obs;
  final occupationTypeList = <String>[].obs;
  final signList = <String>[].obs;
  final memberNo = ''.obs;
  final firstName = ''.obs;
  final middleName = ''.obs;
  final lastName = ''.obs;
  final firstNameEn = ''.obs;
  final lastNameEn = ''.obs;
  final dob = ''.obs;
  final tob = ''.obs;
  final weight = ''.obs;
  final height = ''.obs;
  final gender = 'Male'.obs;
  final maritalStatus = 'Married'.obs;
  final bloodGroup = 'A+'.obs;
  final sign = 'Aries'.obs;
  final isActive = true.obs;
  final mobileNo = ''.obs;
  final mobileVerified = false.obs;
  final secondaryMobile = ''.obs;
  final email = ''.obs;
  final entryPersonMobile = ''.obs;
  final emergencyContactName = ''.obs;
  final emergencyContactNo = ''.obs;
  final isFamilyHead = false.obs;
  final relation = 'Self'.obs;
  final motherFatherName = ''.obs;
  final gotra = ''.obs;
  final mothersGotra = ''.obs;
  final gotraList = <String>[].obs;
  final mothersGotraList = <String>[].obs;
  final openToMarriage = false.obs;
  final ownLand = false.obs;
  final ownHouse = false.obs;
  final twoWheeler = false.obs;
  final fourWheeler = false.obs;
  final monthlyIncome = ''.obs;
  final facebook = ''.obs;
  final whatsapp = ''.obs;
  final instagram = ''.obs;
  final twitter = ''.obs;
  final addresses = <AddressModel>[].obs;
  final educationList = <EducationModel>[].obs;
  final occupationType = 'Agriculture'.obs;
  final occupation = ''.obs;
  final jobPosition = ''.obs;
  final otherJobPosition = ''.obs;
  final otherOccupation = ''.obs;
  final companyName = ''.obs;
  final businessName = ''.obs;
  final workMonthlyIncome = ''.obs;
  final occupationDescription = ''.obs;
  final workState = ''.obs;
  final workDistrict = ''.obs;
  final workTaluka = ''.obs;
  final workArea = ''.obs;
  final workAddressLine1 = ''.obs;
  final workAddressLine2 = ''.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxDouble uploadProgress = 0.0.obs;
  late final TextEditingController memberNoCtrl;
  late final TextEditingController tobCtrl;
  late final TextEditingController motherFatherNameCtrl;
  late final TextEditingController companyNameCtrl;
  late final TextEditingController businessNameCtrl;
  late final TextEditingController entryPersonMobileCtrl;
  late final TextEditingController firstNameCtrl;
  late final TextEditingController middleNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController firstNameEnCtrl;
  late final TextEditingController lastNameEnCtrl;
  late final TextEditingController dobCtrl;
  late final TextEditingController heightCtrl;
  late final TextEditingController weightCtrl;

  late final TextEditingController mobileCtrl;
  late final TextEditingController secondaryMobileCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController emergencyNameCtrl;
  late final TextEditingController emergencyNoCtrl;

  late final TextEditingController monthlyIncomeCtrl;

  late final TextEditingController facebookCtrl;
  late final TextEditingController whatsappCtrl;
  late final TextEditingController instagramCtrl;
  late final TextEditingController twitterCtrl;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    loadAllDropdowns();
  }

  void loadFromMember(Member m) {
    _currentMember = m;
    memberNo.value = m.memberNo ?? '';
    firstName.value = m.firstName;
    middleName.value = m.middleName ?? '';
    lastName.value = m.lastName;
    dob.value = m.dateOfBirth ?? '';
    tob.value = m.dateOfBirthTime ?? '';
    weight.value = m.weight?.toString() ?? '';
    height.value = m.height?.toString() ?? '';
    gender.value = m.genderName ?? '';
    maritalStatus.value = m.maritalStatusName ?? '';
    bloodGroup.value = m.bloodGroupName ?? '';

    mobileNo.value = m.mobileNo ?? '';
    secondaryMobile.value = m.secondaryMobile ?? '';
    email.value = m.emailAddress ?? '';
    emergencyContactName.value = m.emergencyContactName ?? '';
    emergencyContactNo.value = m.emergencyContactNo ?? '';

    motherFatherName.value = m.motherFatherName ?? '';
    gotra.value = m.gotraName ?? '';
    openToMarriage.value = m.isLookingforMarriage ?? false;

    ownLand.value = m.isOwnLand ?? false;
    ownHouse.value = m.isOwnHouse ?? false;
    twoWheeler.value = m.hasTwoWheeler ?? false;
    fourWheeler.value = m.hasFourWheeler ?? false;
    monthlyIncome.value = m.monthlyIncome?.toString() ?? '';

    facebook.value = m.facebookUrl ?? '';
    whatsapp.value = m.whatsappUrl ?? '';
    instagram.value = m.instagramUrl ?? '';
    twitter.value = m.twitterUrl ?? '';

    occupationType.value = m.occupationTypeName ?? '';
    occupation.value = m.occupationName ?? '';
    jobPosition.value = m.jobPositionName ?? '';
    otherJobPosition.value = m.otherJobPosition ?? '';
    otherOccupation.value = m.otherOccupation ?? '';
    companyName.value = m.companyName ?? '';
    businessName.value = m.businessName ?? '';
    occupationDescription.value = m.occupationDescription ?? '';
    workState.value = m.occupationStateName ?? '';
    workDistrict.value = m.occupationDistrictName ?? '';
    workTaluka.value = m.occupationTalukaName ?? '';
    workArea.value = m.occupationAreaName ?? '';
    workAddressLine1.value = m.occupationAddressLine1 ?? '';
    workAddressLine2.value = m.occupationAddressLine2 ?? '';

    memberNoCtrl.text = memberNo.value;
    tobCtrl.text = tob.value;
    motherFatherNameCtrl.text = motherFatherName.value;
    companyNameCtrl.text = companyName.value;
    businessNameCtrl.text = businessName.value;
    entryPersonMobileCtrl.text = entryPersonMobile.value;
    firstNameCtrl.text = firstName.value;
    middleNameCtrl.text = middleName.value;
    lastNameCtrl.text = lastName.value;
    firstNameEnCtrl.text = firstNameEn.value;
    lastNameEnCtrl.text = lastNameEn.value;
    dobCtrl.text = dob.value;
    heightCtrl.text = height.value;
    weightCtrl.text = weight.value;

    mobileCtrl.text = mobileNo.value;
    secondaryMobileCtrl.text = secondaryMobile.value;
    emailCtrl.text = email.value;
    emergencyNameCtrl.text = emergencyContactName.value;
    emergencyNoCtrl.text = emergencyContactNo.value;

    monthlyIncomeCtrl.text = monthlyIncome.value;

    facebookCtrl.text = facebook.value;
    whatsappCtrl.text = whatsapp.value;
    instagramCtrl.text = instagram.value;
    twitterCtrl.text = twitter.value;
  }

  void _initializeControllers() {
    memberNoCtrl = TextEditingController(text: memberNo.value);
    tobCtrl = TextEditingController(text: tob.value);
    motherFatherNameCtrl = TextEditingController(text: motherFatherName.value);
    companyNameCtrl = TextEditingController(text: companyName.value);
    businessNameCtrl = TextEditingController(text: businessName.value);
    entryPersonMobileCtrl = TextEditingController(
      text: entryPersonMobile.value,
    );
    firstNameCtrl = TextEditingController(text: firstName.value);
    middleNameCtrl = TextEditingController(text: middleName.value);
    lastNameCtrl = TextEditingController(text: lastName.value);
    firstNameEnCtrl = TextEditingController(text: firstNameEn.value);
    lastNameEnCtrl = TextEditingController(text: lastNameEn.value);
    dobCtrl = TextEditingController(text: dob.value);
    heightCtrl = TextEditingController(text: height.value);
    weightCtrl = TextEditingController(text: weight.value);

    mobileCtrl = TextEditingController(text: mobileNo.value);
    secondaryMobileCtrl = TextEditingController(text: secondaryMobile.value);
    emailCtrl = TextEditingController(text: email.value);
    emergencyNameCtrl = TextEditingController(text: emergencyContactName.value);
    emergencyNoCtrl = TextEditingController(text: emergencyContactNo.value);

    monthlyIncomeCtrl = TextEditingController(text: monthlyIncome.value);

    facebookCtrl = TextEditingController(text: facebook.value);
    whatsappCtrl = TextEditingController(text: whatsapp.value);
    instagramCtrl = TextEditingController(text: instagram.value);
    twitterCtrl = TextEditingController(text: twitter.value);
  }

  @override
  void onClose() {
    Future<void>.delayed(Duration(milliseconds: 500), () {
      memberNoCtrl.dispose();
      tobCtrl.dispose();
      motherFatherNameCtrl.dispose();
      companyNameCtrl.dispose();
      businessNameCtrl.dispose();
      entryPersonMobileCtrl.dispose();
      firstNameCtrl.dispose();
      middleNameCtrl.dispose();
      lastNameCtrl.dispose();
      firstNameEnCtrl.dispose();
      lastNameEnCtrl.dispose();
      dobCtrl.dispose();
      heightCtrl.dispose();
      weightCtrl.dispose();
      mobileCtrl.dispose();
      secondaryMobileCtrl.dispose();
      emailCtrl.dispose();
      emergencyNameCtrl.dispose();
      emergencyNoCtrl.dispose();
      monthlyIncomeCtrl.dispose();
      facebookCtrl.dispose();
      whatsappCtrl.dispose();
      instagramCtrl.dispose();
      twitterCtrl.dispose();
    });
    super.onClose();
  }

  Future<void> loadAllDropdowns() async {
    await Future.wait([
      _fetchDropdown('/gender/dropdown', genderList, defaultGenders),
      _fetchDropdown(
        '/MaritalStatus/dropdown',
        maritalStatusList,
        defaultMaritalStatuses,
      ),
      _fetchDropdown(
        '/BloodGroup/dropdown',
        bloodGroupList,
        defaultBloodGroups,
      ),
      _fetchDropdown('/RelationType/dropdown', relationList, defaultRelations),
      _fetchDropdown(
        '/AddressType/dropdown',
        addressTypeList,
        defaultAddressTypes,
      ),
      _fetchDropdown(
        '/EducationalQualification/list/dropdown',
        qualificationList,
        defaultQualifications,
      ),
      _fetchDropdown(
        '/Occupation/dropdown',
        occupationTypeList,
        defaultOccupationTypes,
      ),
      _fetchDropdown('/Sign/dropdown', signList, defaultSigns),
      _fetchDropdown('/Gotra/dropdown', gotraList, ['Parmar', 'Chauhan', 'Solanki', 'Rathod']),
      _fetchDropdown('/Gotra/dropdown', mothersGotraList, ['Parmar', 'Chauhan', 'Solanki', 'Rathod']),
    ]);
    _ensureSelectionValue(gender, genderList);
    _ensureSelectionValue(maritalStatus, maritalStatusList);
    _ensureSelectionValue(bloodGroup, bloodGroupList);
    _ensureSelectionValue(relation, relationList);
    _ensureSelectionValue(occupationType, occupationTypeList);
    _ensureSelectionValue(sign, signList);
    _ensureSelectionValue(gotra, gotraList);
    _ensureSelectionValue(mothersGotra, mothersGotraList);
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (list.isNotEmpty && !list.contains(selected.value)) {
      selected.value = list.first;
    }
  }

  Future<void> _fetchDropdown(
    String path,
    RxList<String> targetList,
    List<String> fallbacks,
  ) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1$path');
      if (response.data != null) {
        final json = response.data as Map<String, dynamic>;
        if (json['succeeded'] == true) {
          final rawData = json['data'];
          List<dynamic> list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map<String, dynamic>) {
            list =
                (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ??
                [];
          }
          final items = list
              .map((e) {
                final map = e as Map<String, dynamic>;
                final textKeys = [
                  'text',
                  'Text',
                  'name',
                  'Name',
                  'value',
                  'Value',
                ];
                for (final key in textKeys) {
                  if (map.containsKey(key) && map[key] != null) {
                    return map[key].toString().trim();
                  }
                }
                for (final entry in map.entries) {
                  if (!entry.key.toLowerCase().contains('id')) {
                    return entry.value.toString().trim();
                  }
                }
                return '';
              })
              .where((s) => s.isNotEmpty)
              .toList();

          if (items.isNotEmpty) {
            targetList.assignAll(items);
            return;
          }
        }
      }
    } catch (e) {
    }
    targetList.assignAll(fallbacks);
  }

  void addAddress() {
    addresses.add(
      AddressModel(
        type: addressTypeList.isNotEmpty ? addressTypeList.first : 'Home',
        isPrimary: false,
      ),
    );
  }

  void removeAddress(int index) {
    addresses.removeAt(index);
  }

  void addEducation() {
    educationList.add(
      EducationModel(
        qualification: qualificationList.isNotEmpty
            ? qualificationList.first
            : 'Graduate',
        isHighest: false,
      ),
    );
  }

  void removeEducation(int index) {
    educationList.removeAt(index);
  }

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        croppedFile.path
            .replaceAll('.jpg', '_compressed.jpg')
            .replaceAll('.png', '_compressed.jpg'),
        quality: 75,
        minWidth: 1080,
        minHeight: 1080,
      );
      profileImage.value = compressedFile != null
          ? File(compressedFile.path)
          : File(croppedFile.path);
    }
  }

  void removePhoto() {
    profileImage.value = null;
    uploadProgress.value = 0.0;
  }

  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      firstName.value = firstNameCtrl.text;
      lastName.value = lastNameCtrl.text;
      
      submitThrottled(() async {
        uploadProgress.value = 0.1;
        
        try {
          final memberRepository = Get.find<MemberRepository>();
          final memberToSubmit = Member(
            memberId: _currentMember?.memberId ?? 0,
            memberNo: memberNoCtrl.text,
            firstName: firstNameCtrl.text,
            lastName: lastNameCtrl.text,
            middleName: middleNameCtrl.text,
            mobileNo: mobileCtrl.text,
            emailAddress: emailCtrl.text,
            genderName: gender.value,
            maritalStatusName: maritalStatus.value,
            bloodGroupName: bloodGroup.value,
            dateOfBirth: dob.value,
            dateOfBirthTime: tob.value,
            height: int.tryParse(heightCtrl.text),
            weight: int.tryParse(weightCtrl.text),
            gotraName: gotra.value,
          );

          final result = await memberRepository.updateProfile(memberToSubmit);
          
          if (result.isSuccess) {
            Get.snackbar(
              'Success',
              'Profile updated successfully!',
              backgroundColor: AppColors.green,
              colorText: AppColors.white,
            );
          } else {
            Get.snackbar(
              'Error',
              result.failureOrNull?.message ?? 'Failed to update profile',
              backgroundColor: AppColors.red,
              colorText: AppColors.white,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'An unexpected error occurred.',
            backgroundColor: AppColors.red,
            colorText: AppColors.white,
          );
        } finally {
          uploadProgress.value = 0.0;
        }
      });
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly.',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }
}
