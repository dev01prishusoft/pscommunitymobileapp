import 'dart:io';
import 'dart:convert';
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
  final showListErrors = false.obs;
  Member? _currentMember;
  final Map<String, String> _initialDropdownValues = {};

  late final PersonalInfoController personalInfo;
  late final ContactController contactInfo;
  late final WorkInfoController workInfo;

  @override
  void onInit() {
    super.onInit();
    personalInfo = Get.put(PersonalInfoController(), tag: 'personal');
    contactInfo = Get.put(ContactController(), tag: 'contact');
    workInfo = Get.put(WorkInfoController(), tag: 'work');

    personalInfo.memberNoCtrl.text = generateMemberNo();

    loadAllDropdowns();
  }

  @override
  void onClose() {
    Get.delete<PersonalInfoController>(tag: 'personal');
    Get.delete<ContactController>(tag: 'contact');
    Get.delete<WorkInfoController>(tag: 'work');
    super.onClose();
  }

  String generateMemberNo() {
    final now = DateTime.now();
    final year = now.year;
    final ts = '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return 'PSC-$year-$ts';
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
  RxString get relatedToMemberName => personalInfo.relatedToMemberName;
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
  RxString get otherJobPositionEnglish => workInfo.otherJobPositionEnglish;
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
  TextEditingController get otherJobPositionCtrl => workInfo.otherJobPositionCtrl;
  TextEditingController get otherJobPositionEnglishCtrl => workInfo.otherJobPositionEnglishCtrl;
  TextEditingController get otherOccupationCtrl => workInfo.otherOccupationCtrl;

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
    void addDropdown(String key, RxString rxStr, Map<String, int> idMap, String? originalName, [int? originalId]) {
      final currentStr = rxStr.value; // Read early so Obx registers the dependency
      
      if (!_initialDropdownValues.containsKey(key)) return;

      final initialStr = _initialDropdownValues[key];

      if (currentStr != initialStr) {
        final currentId = getId(currentStr, idMap);
        if (currentId != null) {
          formDataMap[key] = currentId;
        } else {
          formDataMap['_dummy_$key'] = true; // Trigger hasChanges
        }
      }
    }

    addDropdown('GenderId', personalInfo.gender, personalInfo.genderIdMap, m.genderName);
    addDropdown('MaritalStatusId', personalInfo.maritalStatus, personalInfo.maritalStatusIdMap, m.maritalStatusName);
    addDropdown('BloodGroupId', personalInfo.bloodGroup, personalInfo.bloodGroupIdMap, m.bloodGroupName);
    addDropdown('GotraId', personalInfo.gotra, personalInfo.gotraIdMap, m.gotraName, m.gotraId);
    addDropdown('MotherGotraId', personalInfo.mothersGotra, personalInfo.mothersGotraIdMap, null, m.motherGotraId);
    addDropdown('signId', personalInfo.sign, personalInfo.signIdMap, m.signName, m.signId);
    addDropdown('RelationTypeId', personalInfo.relation, personalInfo.relationIdMap, m.relatedToMemberName, m.relationTypeId);
    
    addIfChanged('MotherFatherName', personalInfo.motherFatherName.value, m.motherFatherName ?? '');
    addIfChanged('IsLookingforMarriage', personalInfo.openToMarriage.value, m.isLookingforMarriage ?? false);
    
    addIfChanged('EntryPersonMobileNo', contactInfo.entryPersonMobile.value, m.entryPersonMobileNo ?? '');
    addIfChanged('MobileNo', contactInfo.mobileNo.value, m.mobileNo ?? '');
    addIfChanged('SecondaryMobile', contactInfo.secondaryMobile.value, m.secondaryMobile ?? '');
    addIfChanged('EmailAddress', contactInfo.email.value, m.emailAddress ?? '');
    addIfChanged('EmergencyContactName', contactInfo.emergencyContactName.value, m.emergencyContactName ?? '');
    addIfChanged('EmergencyContactNo', contactInfo.emergencyContactNo.value, m.emergencyContactNo ?? '');
    addIfChanged('FacebookUrl', contactInfo.facebook.value, m.facebookUrl ?? '');
    addIfChanged('WhatsappUrl', contactInfo.whatsapp.value, m.whatsappUrl ?? '');
    addIfChanged('InstagramUrl', contactInfo.instagram.value, m.instagramUrl ?? '');
    addIfChanged('TwitterUrl', contactInfo.twitter.value, m.twitterUrl ?? '');

    addDropdown('OccupationTypeId', workInfo.occupationType, workInfo.occupationTypeIdMap, m.occupationTypeName);
    addIfChanged('OtherOccupation', workInfo.otherOccupation.value, m.otherOccupation ?? '');
    addIfChanged('OtherJobPosition', workInfo.otherJobPosition.value, m.otherJobPosition ?? '');
    addIfChanged('OtherJobPositionEnglish', workInfo.otherJobPositionEnglish.value, '');
    addIfChanged('CompanyName', workInfo.companyName.value, m.companyName ?? '');
    addIfChanged('BusinessName', workInfo.businessName.value, m.businessName ?? '');
    addIfChanged('MonthlyIncome', double.tryParse(personalInfo.monthlyIncome.value), m.monthlyIncome?.toDouble());
    addIfChanged('OccupationDescription', workInfo.occupationDescription.value, m.occupationDescription ?? '');
    
    addIfChanged('IsOwnLand', personalInfo.ownLand.value, m.isOwnLand ?? false);
    addIfChanged('IsOwnHouse', personalInfo.ownHouse.value, m.isOwnHouse ?? false);
    addIfChanged('HasTwoWheeler', personalInfo.twoWheeler.value, m.hasTwoWheeler ?? false);
    addIfChanged('HasFourWheeler', personalInfo.fourWheeler.value, m.hasFourWheeler ?? false);
    
    addDropdown('OccupationTalukaId', workInfo.workTaluka, workInfo.globalTalukaIdMap, m.occupationTalukaName);
    addDropdown('OccupationAreaId', workInfo.workArea, workInfo.workTalukaIdMap, m.occupationAreaName);
    addIfChanged('OccupationAddressLine1', workInfo.workAddressLine1.value, m.occupationAddressLine1 ?? '');
    addIfChanged('OccupationAddressLine2', workInfo.workAddressLine2.value, m.occupationAddressLine2 ?? '');
    addIfChanged('OccupationLandmark', workInfo.workLandmark.value, m.occupationLandmark ?? '');
    addIfChanged('OccupationPincode', workInfo.workPincode.value, m.occupationPincode ?? '');

    return formDataMap;
  }

  String get debugChanges {
    final List<String> details = [];
    for (var key in changedFormData.keys) {
      if (key == 'GenderId' || key == 'MaritalStatusId') {
        final current = key == 'GenderId' ? personalInfo.gender.value : personalInfo.maritalStatus.value;
        final initial = _initialDropdownValues[key];
        details.add('$key("$current" != "$initial")');
      } else {
        details.add(key);
      }
    }
    return details.join(', ');
  }

  bool isAddMode = false;

  bool get hasChanges {
    if (isAddMode) return true;
    if (_currentMember == null) return false;
    if (personalInfo.profileImage.value != null) return true;
    return changedFormData.isNotEmpty;
  }

  void loadFromMember(Member m) {
    _currentMember = m;
    personalInfo.loadFromMember(m);
    contactInfo.loadFromMember(m);
    workInfo.loadFromMember(m);

    isMemberLoaded = true;
    _checkAndTakeSnapshot();
  }

  void markAsAddMode() {
    isAddMode = true;
    isMemberLoaded = true; // Pretend it's loaded so snapshot runs when dropdowns finish
    _checkAndTakeSnapshot();
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
      workInfo.fetchDropdown('/occupation-type/dropdown', workInfo.occupationTypeList, workInfo.defaultOccupationTypes, idMap: workInfo.occupationTypeIdMap),
      workInfo.fetchDropdown('/JobPosition/dropdown', workInfo.jobPositionList, [], idMap: workInfo.jobPositionIdMap),
      workInfo.fetchDropdown('/Sign/dropdown', personalInfo.signList, personalInfo.defaultSigns, idMap: personalInfo.signIdMap),
      workInfo.fetchDropdown(gotraPath, personalInfo.gotraList, [], idMap: personalInfo.gotraIdMap),
      workInfo.fetchDropdown(gotraPath, personalInfo.mothersGotraList, [], idMap: personalInfo.mothersGotraIdMap),
      workInfo.fetchDropdown('/state/dropdown', workInfo.workStateList, [], idMap: workInfo.workStateIdMap),
    ]);
    
    await workInfo.fetchOccupations();
    await workInfo.fetchDistricts();
    await workInfo.fetchTalukas();
    await workInfo.fetchAreas();

    areDropdownsLoaded = true;
    _checkAndTakeSnapshot();
  }

  bool isMemberLoaded = false;
  bool areDropdownsLoaded = false;

  void _checkAndTakeSnapshot() {
    if (isMemberLoaded && areDropdownsLoaded) {
      takeSnapshot();
    }
  }

  void takeSnapshot() {
    _ensureSelectionValue(personalInfo.gender, personalInfo.genderList);
    _ensureSelectionValue(personalInfo.maritalStatus, personalInfo.maritalStatusList);
    _ensureSelectionValue(personalInfo.bloodGroup, personalInfo.bloodGroupList);
    if (_currentMember != null && _currentMember!.relationTypeId != null) {
      final id = _currentMember!.relationTypeId;
      for (final entry in personalInfo.relationIdMap.entries) {
        if (entry.value == id) {
          personalInfo.relation.value = entry.key;
          break;
        }
      }
    }
    if (_currentMember != null && _currentMember!.motherGotraId != null) {
      final id = _currentMember!.motherGotraId;
      for (final entry in personalInfo.mothersGotraIdMap.entries) {
        if (entry.value == id) {
          personalInfo.mothersGotra.value = entry.key;
          break;
        }
      }
    }
    _ensureSelectionValue(personalInfo.relation, personalInfo.relationList);
    if (_currentMember == null && personalInfo.relation.value.isEmpty && personalInfo.relationList.isNotEmpty) {
      personalInfo.relation.value = personalInfo.relationList.first;
    }
    _ensureSelectionValue(workInfo.occupationType, workInfo.occupationTypeList);
    _ensureSelectionValue(workInfo.occupation, workInfo.occupationList);
    _ensureSelectionValue(workInfo.jobPosition, workInfo.jobPositionList);
    _ensureSelectionValue(personalInfo.sign, personalInfo.signList);
    
    if (_currentMember != null) {
      if (_currentMember!.signId != null) {
        final id = _currentMember!.signId;
        for (final entry in personalInfo.signIdMap.entries) {
          if (entry.value == id) {
            personalInfo.sign.value = entry.key;
            break;
          }
        }
      }
      if (_currentMember!.gotraId != null) {
        final id = _currentMember!.gotraId;
        for (final entry in personalInfo.gotraIdMap.entries) {
          if (entry.value == id) {
            personalInfo.gotra.value = entry.key;
            break;
          }
        }
      }
      if (_currentMember!.motherGotraId != null) {
        final id = _currentMember!.motherGotraId;
        for (final entry in personalInfo.mothersGotraIdMap.entries) {
          if (entry.value == id) {
            personalInfo.mothersGotra.value = entry.key;
            break;
          }
        }
      }
    }
    _ensureSelectionValue(personalInfo.gotra, personalInfo.gotraList);
    _ensureSelectionValue(personalInfo.mothersGotra, personalInfo.mothersGotraList);
    _ensureSelectionValue(workInfo.workState, workInfo.workStateList);
    
    _ensureSelectionValue(workInfo.workDistrict, workInfo.workDistrictList);
    
    _ensureSelectionValue(workInfo.workTaluka, workInfo.workTalukaList);
    
    _ensureSelectionValue(workInfo.workArea, workInfo.workAreaList);

    _initialDropdownValues['GenderId'] = personalInfo.gender.value;
    _initialDropdownValues['MaritalStatusId'] = personalInfo.maritalStatus.value;
    _initialDropdownValues['BloodGroupId'] = personalInfo.bloodGroup.value;
    _initialDropdownValues['GotraId'] = personalInfo.gotra.value;
    _initialDropdownValues['MotherGotraId'] = personalInfo.mothersGotra.value;
    _initialDropdownValues['signId'] = personalInfo.sign.value;
    _initialDropdownValues['RelationTypeId'] = personalInfo.relation.value;
    _initialDropdownValues['OccupationTypeId'] = workInfo.occupationType.value;
    _initialDropdownValues['OccupationTalukaId'] = workInfo.workTaluka.value;
    _initialDropdownValues['OccupationAreaId'] = workInfo.workArea.value;

    // Trigger an update so Obx recalculates hasChanges now that snapshot is ready
    changedFormData; 
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (selected.value.isNotEmpty && !list.contains(selected.value)) {
      selected.value = '';
    }
  }

  void submitForm({String? successMessage}) {
    final isEdit = _currentMember != null;
    bool hasListErrors = false;
    
    if (!isEdit) {
      if (addresses.isEmpty || educationList.isEmpty) {
        hasListErrors = true;
      }
    }
    showListErrors.value = hasListErrors;

    if (!hasListErrors && (formKey.currentState?.validate() ?? false)) {
      personalInfo.firstName.value = personalInfo.firstNameCtrl.text;
      personalInfo.lastName.value = personalInfo.lastNameCtrl.text;
      
      submitThrottled(() async {
        personalInfo.uploadProgress.value = 0.1;
        
        try {
          final formDataMap = <String, dynamic>{};
          
          if (isEdit) {
            final formDataChanges = changedFormData;
            formDataMap.addAll(formDataChanges);

            if (personalInfo.profileImage.value != null) {
              final file = personalInfo.profileImage.value!;
              final fileName = file.path.split('/').last;
              formDataMap['ProfileImage'] = await dio.MultipartFile.fromFile(file.path, filename: fileName);
            }
          } else {
            int? getId(String? name, Map<String, int> idMap) {
              if (name == null || name.isEmpty) return null;
              return idMap[name];
            }

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

            formDataMap['FirstName'] = personalInfo.firstNameCtrl.text;
            formDataMap['MiddleName'] = personalInfo.middleNameCtrl.text;
            formDataMap['LastName'] = personalInfo.lastNameCtrl.text;
            formDataMap['FirstNameEnglish'] = personalInfo.firstNameEnCtrl.text;
            formDataMap['LastNameEnglish'] = personalInfo.lastNameEnCtrl.text;
            formDataMap['DateOfBirth'] = formatDob(personalInfo.dob.value);
            formDataMap['DateOfBirthTime'] = personalInfo.tob.value;
            formDataMap['Weight'] = double.tryParse(personalInfo.weightCtrl.text);
            formDataMap['Height'] = double.tryParse(personalInfo.heightCtrl.text);
            formDataMap['GenderId'] = getId(personalInfo.gender.value, personalInfo.genderIdMap);
            formDataMap['MaritalStatusId'] = getId(personalInfo.maritalStatus.value, personalInfo.maritalStatusIdMap);
            formDataMap['BloodGroupId'] = getId(personalInfo.bloodGroup.value, personalInfo.bloodGroupIdMap);
            formDataMap['RelationTypeId'] = getId(personalInfo.relation.value, personalInfo.relationIdMap);
            formDataMap['GotraId'] = getId(personalInfo.gotra.value, personalInfo.gotraIdMap);
            formDataMap['MotherGotraId'] = getId(personalInfo.mothersGotra.value, personalInfo.mothersGotraIdMap);
            formDataMap['MotherFatherName'] = personalInfo.motherFatherNameCtrl.text;
            formDataMap['signId'] = getId(personalInfo.sign.value, personalInfo.signIdMap);
            formDataMap['IsLookingforMarriage'] = personalInfo.openToMarriage.value;
            
            formDataMap['MobileNo'] = contactInfo.mobileCtrl.text;
            formDataMap['SecondaryMobile'] = contactInfo.secondaryMobileCtrl.text;
            formDataMap['EmailAddress'] = contactInfo.emailCtrl.text;
            formDataMap['EmergencyContactName'] = contactInfo.emergencyNameCtrl.text;
            formDataMap['EmergencyContactNo'] = contactInfo.emergencyNoCtrl.text;
            formDataMap['EntryPersonMobileNo'] = contactInfo.entryPersonMobileCtrl.text;
            formDataMap['FacebookUrl'] = contactInfo.facebookCtrl.text;
            formDataMap['WhatsappUrl'] = contactInfo.whatsappCtrl.text;
            formDataMap['InstagramUrl'] = contactInfo.instagramCtrl.text;
            formDataMap['TwitterUrl'] = contactInfo.twitterCtrl.text;
            
            formDataMap['OccupationTypeId'] = getId(workInfo.occupationType.value, workInfo.occupationTypeIdMap);
            formDataMap['OtherOccupation'] = workInfo.otherOccupation.value;
            formDataMap['OtherJobPosition'] = workInfo.otherJobPosition.value;
            formDataMap['OtherJobPositionEnglish'] = workInfo.otherJobPositionEnglish.value;
            formDataMap['CompanyName'] = workInfo.companyNameCtrl.text;
            formDataMap['BusinessName'] = workInfo.businessNameCtrl.text;
            formDataMap['MonthlyIncome'] = double.tryParse(personalInfo.monthlyIncomeCtrl.text);
            formDataMap['OccupationDescription'] = workInfo.occupationDescription.value;
            
            formDataMap['IsOwnLand'] = personalInfo.ownLand.value;
            formDataMap['IsOwnHouse'] = personalInfo.ownHouse.value;
            formDataMap['HasTwoWheeler'] = personalInfo.twoWheeler.value;
            formDataMap['HasFourWheeler'] = personalInfo.fourWheeler.value;
            
            formDataMap['OccupationTalukaId'] = getId(workInfo.workTaluka.value, workInfo.globalTalukaIdMap);
            formDataMap['OccupationAreaId'] = getId(workInfo.workArea.value, workInfo.workTalukaIdMap);
            formDataMap['OccupationAddressLine1'] = workInfo.workAddressLine1Ctrl.text;
            formDataMap['OccupationAddressLine2'] = workInfo.workAddressLine2Ctrl.text;
            formDataMap['OccupationLandmark'] = workInfo.workLandmarkCtrl.text;
            formDataMap['OccupationPincode'] = workInfo.workPincodeCtrl.text;

            formDataMap['IsHead'] = false;
            formDataMap['IsDemised'] = false;
            formDataMap['IsActive'] = true;
            formDataMap['IsMobileVerified'] = contactInfo.mobileVerified.value;
            formDataMap['IssameAddressasMyFamilyHeadAddress'] = true;
            formDataMap['MemberNo'] = personalInfo.memberNoCtrl.text;

            formDataMap['ApproveStatus'] = null;
            formDataMap['ApprovedBy'] = null;
            formDataMap['ApprovedDate'] = null;
            formDataMap['RelatedToMemberId'] = null;
            formDataMap['ProfilePhotoPath'] = null;
            formDataMap['PasswordModifiedDate'] = null;

            if (personalInfo.profileImage.value != null) {
              final file = personalInfo.profileImage.value!;
              final fileName = file.path.split('/').last;
              formDataMap['ProfileImage'] = await dio.MultipartFile.fromFile(file.path, filename: fileName);
            }
          }

          if (formDataMap.isNotEmpty) {
            AppLogger.d('--- API REQUEST ---');
            AppLogger.d('URL: ${isEdit ? '/api/v1/MemberUpdateRequest/create' : '/api/v1/member/mobile/upsert'}');
            final printableMap = formDataMap.map((key, value) {
              if (value is dio.MultipartFile) {
                return MapEntry(key, 'MultipartFile(${value.filename})');
              }
              return MapEntry(key, value);
            });
            debugPrint('Payload: \n${JsonEncoder.withIndent('  ').convert(printableMap)}');

            final formData = dio.FormData.fromMap(formDataMap);
            final apiClient = Get.find<ApiClient>();
            final response = await apiClient.post(
              isEdit ? '/api/v1/MemberUpdateRequest/create' : '/api/v1/member/mobile/upsert',
              data: formData,
            );
            
            AppLogger.d('--- API RESPONSE ---');
            AppLogger.d(response.data?.toString() ?? 'No Response Data');
          }

          Get.back(result: true);
          
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar(
              LK.success.tr,
              successMessage ?? (isEdit ? LK.profileUpdated.tr : 'Member Added Successfully'),
              backgroundColor: AppColors.green,
              colorText: AppColors.white,
            );
          });
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
