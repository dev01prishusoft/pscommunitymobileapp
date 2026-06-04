import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/address_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/education_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/utils/form_state_mixin.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/personal_info_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/contact_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/work_info_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';

class ProfileFormController extends GetxController with FormStateMixin {
  final formKey = GlobalKey<FormState>();
  Member? _currentMember;

  late final PersonalInfoController personalInfo;
  late final ContactController contactInfo;
  late final WorkInfoController workInfo;

  @override
  void onInit() {
    super.onInit();
    personalInfo = Get.put(PersonalInfoController(), tag: 'personal');
    contactInfo = Get.put(ContactController(), tag: 'contact');
    workInfo = Get.put(WorkInfoController(), tag: 'work');

    loadAllDropdowns();
  }

  @override
  void onClose() {
    Get.delete<PersonalInfoController>(tag: 'personal');
    Get.delete<ContactController>(tag: 'contact');
    Get.delete<WorkInfoController>(tag: 'work');
    super.onClose();
  }

  // --- Personal Info Getters ---
  List<String> get defaultGenders => personalInfo.defaultGenders;
  List<String> get defaultMaritalStatuses => personalInfo.defaultMaritalStatuses;
  List<String> get defaultBloodGroups => personalInfo.defaultBloodGroups;
  List<String> get defaultRelations => personalInfo.defaultRelations;
  List<String> get defaultSigns => personalInfo.defaultSigns;
  RxList<String> get genderList => personalInfo.genderList;
  RxList<String> get maritalStatusList => personalInfo.maritalStatusList;
  RxList<String> get bloodGroupList => personalInfo.bloodGroupList;
  RxList<String> get relationList => personalInfo.relationList;
  RxList<String> get signList => personalInfo.signList;
  RxList<String> get gotraList => personalInfo.gotraList;
  RxList<String> get mothersGotraList => personalInfo.mothersGotraList;
  RxString get memberNo => personalInfo.memberNo;
  RxString get firstName => personalInfo.firstName;
  RxString get middleName => personalInfo.middleName;
  RxString get lastName => personalInfo.lastName;
  RxString get firstNameEn => personalInfo.firstNameEn;
  RxString get lastNameEn => personalInfo.lastNameEn;
  RxString get dob => personalInfo.dob;
  RxString get tob => personalInfo.tob;
  RxString get weight => personalInfo.weight;
  RxString get height => personalInfo.height;
  RxString get gender => personalInfo.gender;
  RxString get maritalStatus => personalInfo.maritalStatus;
  RxString get bloodGroup => personalInfo.bloodGroup;
  RxString get sign => personalInfo.sign;
  RxBool get isActive => personalInfo.isActive;
  RxBool get isFamilyHead => personalInfo.isFamilyHead;
  RxString get relation => personalInfo.relation;
  RxString get motherFatherName => personalInfo.motherFatherName;
  RxString get gotra => personalInfo.gotra;
  RxString get mothersGotra => personalInfo.mothersGotra;
  RxBool get openToMarriage => personalInfo.openToMarriage;
  RxBool get ownLand => personalInfo.ownLand;
  RxBool get ownHouse => personalInfo.ownHouse;
  RxBool get twoWheeler => personalInfo.twoWheeler;
  RxBool get fourWheeler => personalInfo.fourWheeler;
  RxString get monthlyIncome => personalInfo.monthlyIncome;
  Rx<File?> get profileImage => personalInfo.profileImage;
  RxDouble get uploadProgress => personalInfo.uploadProgress;
  TextEditingController get memberNoCtrl => personalInfo.memberNoCtrl;
  TextEditingController get tobCtrl => personalInfo.tobCtrl;
  TextEditingController get motherFatherNameCtrl => personalInfo.motherFatherNameCtrl;
  TextEditingController get firstNameCtrl => personalInfo.firstNameCtrl;
  TextEditingController get middleNameCtrl => personalInfo.middleNameCtrl;
  TextEditingController get lastNameCtrl => personalInfo.lastNameCtrl;
  TextEditingController get firstNameEnCtrl => personalInfo.firstNameEnCtrl;
  TextEditingController get lastNameEnCtrl => personalInfo.lastNameEnCtrl;
  TextEditingController get dobCtrl => personalInfo.dobCtrl;
  TextEditingController get heightCtrl => personalInfo.heightCtrl;
  TextEditingController get weightCtrl => personalInfo.weightCtrl;
  TextEditingController get monthlyIncomeCtrl => personalInfo.monthlyIncomeCtrl;

  void pickProfilePhoto() => personalInfo.pickProfilePhoto();
  void removePhoto() => personalInfo.removePhoto();

  // --- Contact Info Getters ---
  List<String> get defaultAddressTypes => contactInfo.defaultAddressTypes;
  List<String> get defaultQualifications => contactInfo.defaultQualifications;
  RxList<String> get addressTypeList => contactInfo.addressTypeList;
  RxList<String> get qualificationList => contactInfo.qualificationList;
  RxString get mobileNo => contactInfo.mobileNo;
  RxBool get mobileVerified => contactInfo.mobileVerified;
  RxString get secondaryMobile => contactInfo.secondaryMobile;
  RxString get email => contactInfo.email;
  RxString get entryPersonMobile => contactInfo.entryPersonMobile;
  RxString get emergencyContactName => contactInfo.emergencyContactName;
  RxString get emergencyContactNo => contactInfo.emergencyContactNo;
  RxString get facebook => contactInfo.facebook;
  RxString get whatsapp => contactInfo.whatsapp;
  RxString get instagram => contactInfo.instagram;
  RxString get twitter => contactInfo.twitter;
  RxList<AddressModel> get addresses => contactInfo.addresses;
  RxList<EducationModel> get educationList => contactInfo.educationList;
  TextEditingController get mobileCtrl => contactInfo.mobileCtrl;
  TextEditingController get secondaryMobileCtrl => contactInfo.secondaryMobileCtrl;
  TextEditingController get emailCtrl => contactInfo.emailCtrl;
  TextEditingController get emergencyNameCtrl => contactInfo.emergencyNameCtrl;
  TextEditingController get emergencyNoCtrl => contactInfo.emergencyNoCtrl;
  TextEditingController get entryPersonMobileCtrl => contactInfo.entryPersonMobileCtrl;
  TextEditingController get facebookCtrl => contactInfo.facebookCtrl;
  TextEditingController get whatsappCtrl => contactInfo.whatsappCtrl;
  TextEditingController get instagramCtrl => contactInfo.instagramCtrl;
  TextEditingController get twitterCtrl => contactInfo.twitterCtrl;

  void addAddress() => contactInfo.addAddress();
  void removeAddress(int index) => contactInfo.removeAddress(index);
  void addEducation() => contactInfo.addEducation();
  void removeEducation(int index) => contactInfo.removeEducation(index);

  // --- Work Info Getters ---
  List<String> get defaultOccupationTypes => workInfo.defaultOccupationTypes;
  RxList<String> get occupationTypeList => workInfo.occupationTypeList;
  RxList<String> get workStateList => workInfo.workStateList;
  RxList<String> get workDistrictList => workInfo.workDistrictList;
  RxList<String> get workTalukaList => workInfo.workTalukaList;
  RxList<String> get workAreaList => workInfo.workAreaList;
  RxString get occupationType => workInfo.occupationType;
  RxString get occupation => workInfo.occupation;
  RxString get jobPosition => workInfo.jobPosition;
  RxString get otherJobPosition => workInfo.otherJobPosition;
  RxString get otherOccupation => workInfo.otherOccupation;
  RxString get companyName => workInfo.companyName;
  RxString get businessName => workInfo.businessName;
  RxString get workMonthlyIncome => workInfo.workMonthlyIncome;
  RxString get occupationDescription => workInfo.occupationDescription;
  RxString get workState => workInfo.workState;
  RxString get workDistrict => workInfo.workDistrict;
  RxString get workTaluka => workInfo.workTaluka;
  RxString get workArea => workInfo.workArea;
  RxString get workAddressLine1 => workInfo.workAddressLine1;
  RxString get workAddressLine2 => workInfo.workAddressLine2;
  RxString get workLandmark => workInfo.workLandmark;
  RxString get workPincode => workInfo.workPincode;
  TextEditingController get companyNameCtrl => workInfo.companyNameCtrl;
  TextEditingController get businessNameCtrl => workInfo.businessNameCtrl;
  TextEditingController get workAddressLine1Ctrl => workInfo.workAddressLine1Ctrl;
  TextEditingController get workAddressLine2Ctrl => workInfo.workAddressLine2Ctrl;
  TextEditingController get workLandmarkCtrl => workInfo.workLandmarkCtrl;
  TextEditingController get workPincodeCtrl => workInfo.workPincodeCtrl;
  TextEditingController get jobPositionCtrl => workInfo.jobPositionCtrl;

  RxList<String> getAddressDistricts(String stateName) => workInfo.getAddressDistricts(stateName);
  RxList<String> getAddressTalukas(String districtName) => workInfo.getAddressTalukas(districtName);
  RxList<String> getAddressAreas(String talukaName) => workInfo.getAddressAreas(talukaName);

  Member? get currentMember => _currentMember;

  Map<String, dynamic> get changedFormData {
    final formDataMap = <String, dynamic>{};
    if (_currentMember == null) return formDataMap;
    final m = _currentMember!;

    void addIfChanged(String key, dynamic currentValue, dynamic originalValue) {
      if (currentValue != originalValue) {
        if (currentValue is String && currentValue.isEmpty && (originalValue == null || (originalValue is String && originalValue.isEmpty))) {
          return;
        }
        formDataMap[key] = currentValue;
      }
    }

    int? getId(String? name, Map<String, int> idMap) {
      if (name == null || name.isEmpty) return null;
      return idMap[name];
    }

    addIfChanged('FirstName', personalInfo.firstName.value, m.firstName);
    addIfChanged('MiddleName', personalInfo.middleName.value, m.middleName ?? '');
    addIfChanged('LastName', personalInfo.lastName.value, m.lastName);
    
    String? formatDob(String? d) {
       if (d == null || d.isEmpty) return null;
       try {
         DateTime dt;
         if (d.contains('-') && d.split('-')[0].length == 2) {
           final parts = d.split('-');
           dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
         } else {
           dt = DateTime.parse(d);
         }
         return dt.toIso8601String();
       } catch (_) {
         return d;
       }
    }
    addIfChanged('DateOfBirth', formatDob(personalInfo.dob.value), formatDob(m.dateOfBirth));
    addIfChanged('DateOfBirthTime', personalInfo.tob.value, m.dateOfBirthTime ?? '');
    
    addIfChanged('Weight', double.tryParse(personalInfo.weight.value), m.weight?.toDouble());
    addIfChanged('Height', double.tryParse(personalInfo.height.value), m.height?.toDouble());
    addIfChanged('GenderId', getId(personalInfo.gender.value, personalInfo.genderIdMap), getId(m.genderName, personalInfo.genderIdMap));
    addIfChanged('MaritalStatusId', getId(personalInfo.maritalStatus.value, personalInfo.maritalStatusIdMap), getId(m.maritalStatusName, personalInfo.maritalStatusIdMap));
    addIfChanged('GotraId', getId(personalInfo.gotra.value, personalInfo.gotraIdMap), getId(m.gotraName, personalInfo.gotraIdMap));
    addIfChanged('MotherGotraId', getId(personalInfo.mothersGotra.value, personalInfo.mothersGotraIdMap), getId(m.motherFatherName, personalInfo.mothersGotraIdMap)); 
    addIfChanged('MotherFatherName', personalInfo.motherFatherName.value, m.motherFatherName ?? '');
    addIfChanged('signId', getId(personalInfo.sign.value, personalInfo.signIdMap), getId(m.gotraName, personalInfo.signIdMap)); 
    
    addIfChanged('IsLookingforMarriage', personalInfo.openToMarriage.value, m.isLookingforMarriage ?? false);
    
    addIfChanged('SecondaryMobile', contactInfo.secondaryMobile.value, m.secondaryMobile ?? '');
    addIfChanged('EmailAddress', contactInfo.email.value, m.emailAddress ?? '');
    addIfChanged('EmergencyContactName', contactInfo.emergencyContactName.value, m.emergencyContactName ?? '');
    addIfChanged('EmergencyContactNo', contactInfo.emergencyContactNo.value, m.emergencyContactNo ?? '');
    addIfChanged('FacebookUrl', contactInfo.facebook.value, m.facebookUrl ?? '');
    addIfChanged('WhatsappUrl', contactInfo.whatsapp.value, m.whatsappUrl ?? '');
    addIfChanged('InstagramUrl', contactInfo.instagram.value, m.instagramUrl ?? '');
    addIfChanged('TwitterUrl', contactInfo.twitter.value, m.twitterUrl ?? '');

    addIfChanged('OccupationTypeId', getId(workInfo.occupationType.value, workInfo.occupationTypeIdMap), getId(m.occupationTypeName, workInfo.occupationTypeIdMap));
    addIfChanged('OtherOccupation', workInfo.otherOccupation.value, m.otherOccupation ?? '');
    addIfChanged('OtherJobPosition', workInfo.otherJobPosition.value, m.otherJobPosition ?? '');
    addIfChanged('CompanyName', workInfo.companyName.value, m.companyName ?? '');
    addIfChanged('BusinessName', workInfo.businessName.value, m.businessName ?? '');
    addIfChanged('MonthlyIncome', double.tryParse(personalInfo.monthlyIncome.value), m.monthlyIncome?.toDouble());
    addIfChanged('OccupationDescription', workInfo.occupationDescription.value, m.occupationDescription ?? '');
    
    addIfChanged('IsOwnLand', personalInfo.ownLand.value, m.isOwnLand ?? false);
    addIfChanged('IsOwnHouse', personalInfo.ownHouse.value, m.isOwnHouse ?? false);
    addIfChanged('HasTwoWheeler', personalInfo.twoWheeler.value, m.hasTwoWheeler ?? false);
    addIfChanged('HasFourWheeler', personalInfo.fourWheeler.value, m.hasFourWheeler ?? false);
    
    addIfChanged('OccupationTalukaId', getId(workInfo.workTaluka.value, workInfo.globalTalukaIdMap), m.talukaId);
    addIfChanged('OccupationAreaId', getId(workInfo.workArea.value, workInfo.workTalukaIdMap), m.areaId); 
    addIfChanged('OccupationAddressLine1', workInfo.workAddressLine1.value, m.occupationAddressLine1 ?? '');
    addIfChanged('OccupationAddressLine2', workInfo.workAddressLine2.value, m.occupationAddressLine2 ?? '');
    addIfChanged('OccupationLandmark', workInfo.workLandmark.value, m.occupationLandmark ?? '');
    addIfChanged('OccupationPincode', workInfo.workPincode.value, m.occupationPincode ?? '');

    return formDataMap;
  }

  bool get hasChanges {
    if (_currentMember == null) return true;
    if (personalInfo.profileImage.value != null) return true;
    return changedFormData.isNotEmpty;
  }

  void loadFromMember(Member m) {
    _currentMember = m;
    personalInfo.loadFromMember(m);
    contactInfo.loadFromMember(m);
    workInfo.loadFromMember(m);
  }

  Future<void> loadAllDropdowns() async {
    final tokenManager = Get.find<TokenManager>();
    final samajId = tokenManager.samajId;
    final gotraPath = samajId != null ? '/Gotra/dropdown?samajId=$samajId' : '/Gotra/dropdown';

    await Future.wait([
      workInfo.fetchDropdown('/gender/dropdown', personalInfo.genderList, personalInfo.defaultGenders, idMap: personalInfo.genderIdMap),
      workInfo.fetchDropdown('/MaritalStatus/dropdown', personalInfo.maritalStatusList, personalInfo.defaultMaritalStatuses, idMap: personalInfo.maritalStatusIdMap),
      workInfo.fetchDropdown('/BloodGroup/dropdown', personalInfo.bloodGroupList, personalInfo.defaultBloodGroups, idMap: personalInfo.bloodGroupIdMap),
      workInfo.fetchDropdown('/RelationType/dropdown', personalInfo.relationList, personalInfo.defaultRelations, idMap: personalInfo.relationIdMap),
      workInfo.fetchDropdown('/AddressType/dropdown', contactInfo.addressTypeList, contactInfo.defaultAddressTypes),
      workInfo.fetchDropdown('/EducationalQualification/list/dropdown', contactInfo.qualificationList, contactInfo.defaultQualifications),
      workInfo.fetchDropdown('/api/v1/Occupation/dropdown', workInfo.occupationTypeList, workInfo.defaultOccupationTypes, idMap: workInfo.occupationTypeIdMap),
      workInfo.fetchDropdown('/Sign/dropdown', personalInfo.signList, personalInfo.defaultSigns, idMap: personalInfo.signIdMap),
      workInfo.fetchDropdown(gotraPath, personalInfo.gotraList, [], idMap: personalInfo.gotraIdMap),
      workInfo.fetchDropdown(gotraPath, personalInfo.mothersGotraList, [], idMap: personalInfo.mothersGotraIdMap),
      workInfo.fetchDropdown('/state/dropdown', workInfo.workStateList, [], idMap: workInfo.workStateIdMap),
    ]);
    
    _ensureSelectionValue(personalInfo.gender, personalInfo.genderList);
    _ensureSelectionValue(personalInfo.maritalStatus, personalInfo.maritalStatusList);
    _ensureSelectionValue(personalInfo.bloodGroup, personalInfo.bloodGroupList);
    _ensureSelectionValue(personalInfo.relation, personalInfo.relationList);
    _ensureSelectionValue(workInfo.occupationType, workInfo.occupationTypeList);
    _ensureSelectionValue(personalInfo.sign, personalInfo.signList);
    _ensureSelectionValue(personalInfo.gotra, personalInfo.gotraList);
    _ensureSelectionValue(personalInfo.mothersGotra, personalInfo.mothersGotraList);
    _ensureSelectionValue(workInfo.workState, workInfo.workStateList);
    
    await workInfo.fetchDistricts();
    _ensureSelectionValue(workInfo.workDistrict, workInfo.workDistrictList);
    
    await workInfo.fetchTalukas();
    _ensureSelectionValue(workInfo.workTaluka, workInfo.workTalukaList);
    
    await workInfo.fetchAreas();
    _ensureSelectionValue(workInfo.workArea, workInfo.workAreaList);
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (selected.value.isNotEmpty && !list.contains(selected.value)) {
      selected.value = '';
    }
  }

  void submitForm({String? successMessage}) {
    if (formKey.currentState?.validate() ?? false) {
      personalInfo.firstName.value = personalInfo.firstNameCtrl.text;
      personalInfo.lastName.value = personalInfo.lastNameCtrl.text;
      
      submitThrottled(() async {
        personalInfo.uploadProgress.value = 0.1;
        
        try {
          final isEdit = _currentMember != null;
          final formDataMap = <String, dynamic>{};
          
          if (isEdit) {
            final formDataChanges = changedFormData;
            formDataMap.addAll(formDataChanges);

            if (personalInfo.profileImage.value != null) {
              final file = personalInfo.profileImage.value!;
              final fileName = file.path.split('/').last;
              formDataMap['ProfileImage'] = await dio.MultipartFile.fromFile(file.path, filename: fileName);
            }
          }

          if (formDataMap.isNotEmpty) {
            final formData = dio.FormData.fromMap(formDataMap);
            final apiClient = Get.find<ApiClient>();
            await apiClient.post(
              '/api/v1/MemberUpdateRequest/create',
              data: formData,
            );
          }

          Get.snackbar(
            LK.success.tr,
            successMessage ?? (isEdit ? LK.profileUpdated.tr : 'Member Added Successfully'),
            backgroundColor: AppColors.green,
            colorText: AppColors.white,
          );
        } catch (e, stack) {
          AppLogger.e('Submit form error', e, stack);
          Get.snackbar(
            LK.error.tr,
            LK.unexpectedError.tr,
            backgroundColor: AppColors.red,
            colorText: AppColors.white,
          );
        } finally {
          personalInfo.uploadProgress.value = 0.0;
        }
      });
    } else {
      Get.snackbar(
        LK.errorValidation.tr,
        LK.pleaseFillRequiredFields.tr,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }
}
