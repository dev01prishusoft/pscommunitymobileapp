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
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/personal_info_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/contact_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/work_info_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
class ProfileFormController extends GetxController with FormStateMixin {
  final formKey = GlobalKey<FormState>();
  final showListErrors = false.obs;
  Member? _currentMember;
  final Map<String, String> _initialDropdownValues = {};
  final RxMap<String, ProfileUpdateStatus> fieldStatuses = <String, ProfileUpdateStatus>{}.obs;
  final TextEditingController editRequestCommentCtrl = TextEditingController();
  final RxString editRequestComment = ''.obs;

  late final PersonalInfoController personalInfo;
  late final ContactController contactInfo;
  late final WorkInfoController workInfo;

  @override
  void onInit() {
    super.onInit();
    personalInfo = Get.put(PersonalInfoController(), tag: 'personal');
    contactInfo = Get.put(ContactController(), tag: 'contact');
    workInfo = Get.put(WorkInfoController(), tag: 'work');

    editRequestCommentCtrl.addListener(() => editRequestComment.value = editRequestCommentCtrl.text);

    loadAllDropdowns();
  }

  @override
  void onClose() {
    Get.delete<PersonalInfoController>(tag: 'personal');
    Get.delete<ContactController>(tag: 'contact');
    Get.delete<WorkInfoController>(tag: 'work');
    editRequestCommentCtrl.dispose();
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
  
  bool get shouldHideLookingForMarriage {
    final s = maritalStatus.value.trim().toLowerCase();
    final isUnmarried = s.contains('unmarried') || s.contains('અપરિણીત') || s.contains('single') || s.contains('સિંગલ');
    if (isUnmarried) return false;
    
    final isMarried = s.contains('married') || s.contains('પરિણીત');
    final isDivorced = s.contains('divorced') || s.contains('છૂટાછેડા');
    
    return isMarried || isDivorced;
  }

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
  TextEditingController get occupationDescriptionCtrl => workInfo.occupationDescriptionCtrl;

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
    addIfChanged('FirstNameEnglish', personalInfo.firstNameEn.value, m.firstNameEnglish ?? '');
    addIfChanged('MiddleName', personalInfo.middleName.value, m.middleName ?? '');
    addIfChanged('LastName', personalInfo.lastName.value, m.lastName);
    addIfChanged('LastNameEnglish', personalInfo.lastNameEn.value, m.lastNameEnglish ?? '');
    
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
         return dt.toIso8601String().replaceAll('Z', '');
       } catch (_) {
         return d;
       }
    }
    addIfChanged('DateOfBirth', formatDob(personalInfo.dob.value), formatDob(m.dateOfBirth));
    addIfChanged('DateOfBirthTime', personalInfo.tob.value, m.dateOfBirthTime ?? '');
    
    double? normDouble(double? v) => (v == null || v == 0.0) ? null : v;
    
    addIfChanged('Weight', normDouble(double.tryParse(personalInfo.weight.value)), normDouble(m.weight?.toDouble()));
    addIfChanged('Height', normDouble(double.tryParse(personalInfo.height.value)), normDouble(m.height?.toDouble()));
    void addDropdown(String key, RxString rxStr, Map<String, int> idMap, String? originalName, [int? originalId]) {
      final currentStr = rxStr.value; // Read early so Obx registers the dependency
      
      if (!_initialDropdownValues.containsKey(key)) return;

      final initialStr = _initialDropdownValues[key];

      if (currentStr != initialStr) {
        final currentId = getId(currentStr, idMap);
        if (currentId != null) {
          formDataMap[key] = currentId;
        } else if (currentStr.isEmpty && initialStr != null && initialStr.isNotEmpty) {
          formDataMap[key] = null;
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
    addDropdown('MotherAreaId', personalInfo.motherArea, workInfo.globalAreaIdMap, m.motherAreaName, m.motherAreaId);
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
    addDropdown('OccupationId', workInfo.occupation, workInfo.occupationIdMap, m.occupationName);
    addDropdown('JobPositionId', workInfo.jobPosition, workInfo.jobPositionIdMap, m.jobPositionName);
    addIfChanged('OtherOccupation', workInfo.otherOccupation.value, m.otherOccupation ?? '');
    addIfChanged('OtherJobPosition', workInfo.otherJobPosition.value, m.otherJobPosition ?? '');
    addIfChanged('OtherJobPositionEnglish', workInfo.otherJobPositionEnglish.value, '');
    addIfChanged('CompanyName', workInfo.companyName.value, m.companyName ?? '');
    addIfChanged('BusinessName', workInfo.businessName.value, m.businessName ?? '');
    addIfChanged('MonthlyIncome', normDouble(double.tryParse(personalInfo.monthlyIncome.value)), normDouble(m.monthlyIncome?.toDouble()));
    addIfChanged('OccupationDescription', workInfo.occupationDescription.value, m.occupationDescription ?? '');
    
    addIfChanged('IsOwnLand', personalInfo.ownLand.value, m.isOwnLand ?? false);
    addIfChanged('IsOwnHouse', personalInfo.ownHouse.value, m.isOwnHouse ?? false);
    addIfChanged('HasTwoWheeler', personalInfo.twoWheeler.value, m.hasTwoWheeler ?? false);
    addIfChanged('HasFourWheeler', personalInfo.fourWheeler.value, m.hasFourWheeler ?? false);
    
    addDropdown('OccupationStateId', workInfo.workState, workInfo.workStateIdMap, m.occupationStateName);
    addDropdown('OccupationDistrictId', workInfo.workDistrict, workInfo.workDistrictIdMap, m.occupationDistrictName);
    addDropdown('OccupationTalukaId', workInfo.workTaluka, workInfo.workTalukaIdMap, m.occupationTalukaName);
    addDropdown('OccupationAreaId', workInfo.workArea, workInfo.workAreaIdMap, m.occupationAreaName);
    addIfChanged('OccupationAddressLine1', workInfo.workAddressLine1.value, m.occupationAddressLine1 ?? '');
    addIfChanged('OccupationAddressLine2', workInfo.workAddressLine2.value, m.occupationAddressLine2 ?? '');
    addIfChanged('OccupationLandmark', workInfo.workLandmark.value, m.occupationLandmark ?? '');
    addIfChanged('OccupationPincode', workInfo.workPincode.value, m.occupationPincode ?? '');
    
    final currentEduJson = jsonEncode(educationList.map((e) => e.toJson()).toList());
    if (currentEduJson != _initialEducationJson) {
      if (educationList.isNotEmpty) {
        final edu = educationList.first;
        Map<String, dynamic>? initialEdu;
        if (_initialEducationJson.isNotEmpty && _initialEducationJson != '[]') {
          final decoded = jsonDecode(_initialEducationJson) as List<dynamic>;
          if (decoded.isNotEmpty) initialEdu = decoded.first as Map<String, dynamic>;
        }
        
        final qualId = contactInfo.educationIdMap[edu.qualification] ?? edu.qualificationId;
        final initialQualId = initialEdu?['qualificationId'] as int?;
        if (qualId != initialQualId) formDataMap['EducationalQualificationId'] = qualId;

        void addEdu(String key, String current, String? initial) {
          if (current != (initial ?? '')) {
            formDataMap[key] = current.isEmpty ? null : current;
          }
        }
        
        addEdu('InstitutionName', edu.institute, initialEdu?['institute'] as String?);
        addEdu('YearOfPassing', edu.passingYear, initialEdu?['passingYear'] as String?);
        addEdu('Grade', edu.grade, initialEdu?['grade'] as String?);
        addEdu('Description', edu.description, initialEdu?['description'] as String?);
        
        if (edu.percentage != (initialEdu?['percentage'] as String? ?? '')) {
          formDataMap['Percentage'] = edu.percentage;
        }
      } else {
        formDataMap['EducationalQualificationId'] = null;
        formDataMap['InstitutionName'] = null;
        formDataMap['YearOfPassing'] = null;
        formDataMap['Percentage'] = null;
        formDataMap['Grade'] = null;
        formDataMap['Description'] = null;
      }
    }

    final currentAddrJson = jsonEncode(contactInfo.addresses.map((e) => e.toJson()).toList());
    if (currentAddrJson != _initialAddressesJson) {
      if (contactInfo.addresses.isNotEmpty) {
        final addr = contactInfo.addresses.firstWhere((a) => a.isPrimary, orElse: () => contactInfo.addresses.first);
        Map<String, dynamic>? initialAddr;
        if (_initialAddressesJson.isNotEmpty && _initialAddressesJson != '[]') {
          final decoded = jsonDecode(_initialAddressesJson) as List<dynamic>;
          if (decoded.isNotEmpty) {
            final maps = decoded.cast<Map<String, dynamic>>();
            initialAddr = maps.firstWhere((a) => a['isPrimary'] == true, orElse: () => maps.first);
          }
        }

        final typeId = getId(addr.type, contactInfo.addressTypeIdMap) ?? addr.typeId ?? 0;
        final initialTypeId = initialAddr?['typeId'] as int?;
        if (typeId != initialTypeId && typeId != 0) formDataMap['AddressTypeId'] = typeId;

        void addAddr(String key, String current, String? initial) {
          if (current != (initial ?? '')) {
            formDataMap[key] = current.isEmpty ? null : current;
          }
        }
        addAddr('AddressLine1', addr.line1, initialAddr?['line1'] as String?);
        addAddr('AddressLine2', addr.line2, initialAddr?['line2'] as String?);
        addAddr('Landmark', addr.landmark, initialAddr?['landmark'] as String?);
        addAddr('Pincode', addr.pincode, initialAddr?['pincode'] as String?);

        final areaId = getId(addr.area, workInfo.globalAreaIdMap) ?? addr.areaId ?? 0;
        final initialAreaId = initialAddr?['areaId'] as int?;
        if (areaId != initialAreaId && areaId != 0) formDataMap['AreaId'] = areaId;

        final talukaId = getId(addr.taluka, workInfo.globalTalukaIdMap) ?? addr.talukaId ?? 0;
        final initialTalukaId = initialAddr?['talukaId'] as int?;
        if (talukaId != initialTalukaId && talukaId != 0) formDataMap['TalukaId'] = talukaId;

        final districtId = getId(addr.district, workInfo.globalDistrictIdMap) ?? addr.districtId ?? 0;
        final initialDistrictId = initialAddr?['districtId'] as int?;
        if (districtId != initialDistrictId && districtId != 0) formDataMap['DistrictId'] = districtId;

        final stateId = getId(addr.state, workInfo.globalStateIdMap) ?? addr.stateId ?? 0;
        final initialStateId = initialAddr?['stateId'] as int?;
        if (stateId != initialStateId && stateId != 0) formDataMap['StateId'] = stateId;
      } else {
        formDataMap['AddressTypeId'] = null;
        formDataMap['AddressLine1'] = null;
        formDataMap['AddressLine2'] = null;
        formDataMap['Landmark'] = null;
        formDataMap['Pincode'] = null;
        formDataMap['AreaId'] = null;
        formDataMap['TalukaId'] = null;
        formDataMap['DistrictId'] = null;
        formDataMap['StateId'] = null;
      }
    }

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

  String? getInitialDropdownValue(String key) => _initialDropdownValues[key];

  bool get hasChanges {
    if (isAddMode) return true;
    if (_currentMember == null) return false;
    if (personalInfo.profileImage.value != null) return true;
    if (personalInfo.isPhotoRemoved.value) return true;
    
    // Force Obx dependency registration
    // ignore: unused_local_variable
    final eduList = educationList.toList();
    // ignore: unused_local_variable
    final addrList = contactInfo.addresses.toList();
    
    final currentEduJson = jsonEncode(eduList.map((e) => e.toJson()).toList());
    if (currentEduJson != _initialEducationJson) {
      return true;
    }
    
    final currentAddrJson = jsonEncode(addrList.map((e) => e.toJson()).toList());
    if (currentAddrJson != _initialAddressesJson) {
      return true;
    }
    
    final map = changedFormData;
    if (map.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool get hasMotherAddressChanged {
    if (_currentMember == null) return true;
    return personalInfo.motherState.value != (_currentMember!.motherStateName ?? '') ||
           personalInfo.motherDistrict.value != (_currentMember!.motherDistrictName ?? '') ||
           personalInfo.motherTaluka.value != (_currentMember!.motherTalukaName ?? '') ||
           personalInfo.motherArea.value != (_currentMember!.motherAreaName ?? '');
  }

  bool get hasWorkAddressChanged {
    if (_currentMember == null) return true;
    return workInfo.workState.value != (_currentMember!.occupationStateName ?? '') ||
           workInfo.workDistrict.value != (_currentMember!.occupationDistrictName ?? '') ||
           workInfo.workTaluka.value != (_currentMember!.occupationTalukaName ?? '') ||
           workInfo.workArea.value != (_currentMember!.occupationAreaName ?? '');
  }

  bool get hasContactAddressChanged {
    final currentAddrJson = jsonEncode(contactInfo.addresses.map((e) => e.toJson()).toList());
    return currentAddrJson != _initialAddressesJson;
  }

  void loadFromMember(Member m) {
    _currentMember = m;
    personalInfo.loadFromMember(m);
    contactInfo.loadFromMember(m);
    workInfo.loadFromMember(m);

    isMemberLoaded = true;
    _checkAndTakeSnapshot();
    
    int addressMemberId = m.memberId;
    if (m.issameAddressasMyFamilyHeadAddress == true) {
      if (m.relatedToMemberId != null && m.relatedToMemberId! > 0) {
        addressMemberId = m.relatedToMemberId!;
      } else if (m.familyId != null && m.familyId! > 0) {
        addressMemberId = m.familyId!;
      }
    }
    
    // Asynchronously fetch addresses and education for this member
    loadAddresses(addressMemberId);
    loadEducation(m.memberId);
    fetchProfileUpdateStatus();
  }

  Future<void> fetchProfileUpdateStatus() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1/MemberUpdateRequest/profile-status');
      
      if (response.statusCode == 200 && response.data != null && response.data['succeeded'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        
        final newStatuses = <String, ProfileUpdateStatus>{};
        for (var item in items) {
          final status = ProfileUpdateStatus.fromJson(item as Map<String, dynamic>);
          newStatuses[status.keyName] = status;
        }
        
        fieldStatuses.value = newStatuses;
      }
    } catch (e, stack) {
      AppLogger.e('Failed to load profile update status', e, stack);
    }
  }

  ProfileUpdateStatus? getUpdateStatus(String keyName, {Map<String, int>? idMap}) {
    // Trigger Obx reactivity correctly for the map
    // ignore: unused_local_variable
    final _ = fieldStatuses.keys.toList();

    ProfileUpdateStatus? status;
    for (final entry in fieldStatuses.entries) {
      if (entry.key.toLowerCase() == keyName.toLowerCase()) {
        status = entry.value;
        break;
      }
    }
    
    // Do not display "Approved" status as requested by user
    if (status == null || status.isApproved) return null;
    
    if (idMap != null && status.newValue != null) {
      final id = int.tryParse(status.newValue!);
      if (id != null) {
        for (final entry in idMap.entries) {
          if (entry.value == id) {
            return ProfileUpdateStatus(
              approvalRequestId: status.approvalRequestId,
              keyName: status.keyName,
              oldValue: status.oldValue,
              newValue: entry.key,
              status: status.status,
              rawJson: status.rawJson,
            );
          }
        }
        
        // Fallback to global maps to find the ID text if missing from the specific dropdown map
        final List<Map<String, int>> globalMaps = [];
        if (keyName.contains('State')) globalMaps.add(workInfo.globalStateIdMap);
        if (keyName.contains('District')) globalMaps.add(workInfo.globalDistrictIdMap);
        if (keyName.contains('Taluka')) {
          globalMaps.add(workInfo.globalTalukaIdMap);
          globalMaps.add(workInfo.workTalukaIdMap);
        }
        if (keyName.contains('Area')) {
          globalMaps.add(workInfo.globalAreaIdMap);
          globalMaps.add(workInfo.workAreaIdMap);
        }
        
        for (final gMap in globalMaps) {
          for (final entry in gMap.entries) {
            if (entry.value == id) {
              return ProfileUpdateStatus(
                approvalRequestId: status.approvalRequestId,
                keyName: status.keyName,
                oldValue: status.oldValue,
                newValue: entry.key,
                status: status.status,
                rawJson: status.rawJson,
              );
            }
          }
        }
      }
    }
    
    // For specific checkboxes
    final lowerKey = keyName.toLowerCase();
    if (lowerKey == 'islookingformarriage' || lowerKey == 'isownland' || lowerKey == 'isownhouse' || lowerKey == 'hastwowheeler' || lowerKey == 'hasfourwheeler') {
       final newValueStr = status.newValue?.toLowerCase() == 'true' ? LK.yes.tr : LK.no.tr;
       return ProfileUpdateStatus(
              approvalRequestId: status.approvalRequestId,
              keyName: status.keyName,
              oldValue: status.oldValue,
              newValue: newValueStr,
              status: status.status,
              rawJson: status.rawJson,
            );
    }
    
    if (keyName == 'DateOfBirth' && status.newValue != null) {
      try {
        final dt = DateTime.parse(status.newValue!);
        final formatted = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
        return ProfileUpdateStatus(
          approvalRequestId: status.approvalRequestId,
          keyName: status.keyName,
          oldValue: status.oldValue,
          newValue: formatted,
          status: status.status,
          rawJson: status.rawJson,
        );
      } catch (_) {}
    }
    if (keyName == 'DateOfBirthTime' && status.newValue != null) {
      try {
        final parts = status.newValue!.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          final int minute = int.parse(parts[1]);
          final period = hour >= 12 ? 'PM' : 'AM';
          if (hour == 0) {
            hour = 12;
          } else if (hour > 12) {
            hour -= 12;
          }
          final formattedTime = '$hour:${minute.toString().padLeft(2, '0')} $period';
          return ProfileUpdateStatus(
            approvalRequestId: status.approvalRequestId,
            keyName: status.keyName,
            oldValue: status.oldValue,
            newValue: formattedTime,
            status: status.status,
            rawJson: status.rawJson,
          );
        }
      } catch (_) {}
    }
    
    return status;
  }

  String _initialEducationJson = '[]';
  String _initialAddressesJson = '[]';

  Future<void> loadEducation(int memberId) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1/MemberEducation/member/$memberId');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        final newEducation = data.map((e) {
          final map = e as Map<String, dynamic>;
          final qualName = map['educationalQualificationName']?.toString() ?? '';

          if (qualName.isNotEmpty) {
            final qualId = map['educationalQualificationId'] as int?;
            if (qualId != null) {
              contactInfo.educationIdMap[qualName] = qualId;
            }
            if (!contactInfo.qualificationList.contains(qualName)) {
              contactInfo.qualificationList.add(qualName);
            }
          }

          return EducationModel(
            qualification: qualName,
            qualificationId: map['educationalQualificationId'] as int?,
            institute: map['institutionName']?.toString() ?? '',
            passingYear: (map['yearOfPassing']?.toString() == '0' || map['yearOfPassing']?.toString() == '0.0') ? '' : (map['yearOfPassing']?.toString() ?? ''),
            percentage: (map['percentage']?.toString() == '0' || map['percentage']?.toString() == '0.0') ? '' : (map['percentage']?.toString() ?? ''),
            grade: map['grade']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            isHighest: map['isHighestQualification'] == true,
          );
        }).toList();

        if (newEducation.isNotEmpty) {
          newEducation.sort((a, b) {
            if (a.isHighest && !b.isHighest) return -1;
            if (!a.isHighest && b.isHighest) return 1;
            return 0;
          });
          contactInfo.educationList.value = newEducation;
        }
        _initialEducationJson = jsonEncode(contactInfo.educationList.map((e) => e.toJson()).toList());
        _checkAndTakeSnapshot();
      }
    } catch (e, stack) {
      AppLogger.e('Failed to load education for member $memberId', e, stack);
    }
  }

  Future<void> loadAddresses(int memberId) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1/member-address/list?MemberId=$memberId&Page=1&PageSize=20');
      if (response.data != null && response.data['succeeded'] == true) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        final newAddresses = data.map((e) {
          final map = e as Map<String, dynamic>;
          final stateName = map['stateName']?.toString() ?? '';
          final districtName = map['districtName']?.toString() ?? '';
          final talukaName = map['talukaName']?.toString() ?? '';
          final areaName = map['areaName']?.toString() ?? '';

          if (stateName.isNotEmpty) {
            final stateId = map['stateId'] as int?;
            if (stateId != null) workInfo.globalStateIdMap[stateName] = stateId;
            if (!workInfo.workStateList.contains(stateName)) {
              workInfo.workStateList.add(stateName);
            }

            if (districtName.isNotEmpty) {
              final districtId = map['districtId'] as int?;
              if (districtId != null) workInfo.globalDistrictIdMap[districtName] = districtId;
              workInfo.addressDistrictCache.putIfAbsent(stateName, () => <String>[].obs);
              if (!workInfo.addressDistrictCache[stateName]!.contains(districtName)) {
                workInfo.addressDistrictCache[stateName]!.add(districtName);
              }

              if (talukaName.isNotEmpty) {
                final talukaId = map['talukaId'] as int?;
                if (talukaId != null) workInfo.globalTalukaIdMap[talukaName] = talukaId;
                workInfo.addressTalukaCache.putIfAbsent(districtName, () => <String>[].obs);
                if (!workInfo.addressTalukaCache[districtName]!.contains(talukaName)) {
                  workInfo.addressTalukaCache[districtName]!.add(talukaName);
                }

                if (areaName.isNotEmpty) {
                  final areaId = map['areaId'] as int?;
                  if (areaId != null) workInfo.globalAreaIdMap[areaName] = areaId;
                  workInfo.addressAreaCache.putIfAbsent(talukaName, () => <String>[].obs);
                  if (!workInfo.addressAreaCache[talukaName]!.contains(areaName)) {
                    workInfo.addressAreaCache[talukaName]!.add(areaName);
                  }
                }
              }
            }
          }

          return AddressModel(
            type: map['addressTypeName']?.toString() ?? '',
            typeId: map['addressTypeId'] as int?,
            state: stateName,
            district: districtName,
            taluka: talukaName,
            area: areaName,
            stateId: map['stateId'] as int?,
            districtId: map['districtId'] as int?,
            talukaId: map['talukaId'] as int?,
            areaId: map['areaId'] as int?,
            pincode: map['pincode']?.toString() ?? '',
            line1: map['addressLine1']?.toString() ?? '',
            line2: map['addressLine2']?.toString() ?? '',
            landmark: map['landmark']?.toString() ?? '',
            isPrimary: map['isPrimary'] == true,
          );
        }).toList();

        // Sort addresses so the primary one is always first
        newAddresses.sort((a, b) {
          if (a.isPrimary && !b.isPrimary) return -1;
          if (!a.isPrimary && b.isPrimary) return 1;
          return 0;
        });

        if (newAddresses.isNotEmpty) {
          contactInfo.addresses.value = newAddresses;
        }
        _initialAddressesJson = jsonEncode(contactInfo.addresses.map((e) => e.toJson()).toList());
        _checkAndTakeSnapshot();
      }
    } catch (e) {
      // Ignore
    }
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
      workInfo.fetchDropdown('/AddressType/dropdown', contactInfo.addressTypeList, contactInfo.defaultAddressTypes, idMap: contactInfo.addressTypeIdMap),
      workInfo.fetchDropdown('/EducationalQualification/list/dropdown', contactInfo.qualificationList, contactInfo.defaultQualifications, idMap: contactInfo.educationIdMap),
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

  Future<void> takeSnapshot() async {
    _ensureSelectionValue(personalInfo.gender, personalInfo.genderList);
    _ensureSelectionValue(personalInfo.maritalStatus, personalInfo.maritalStatusList);
    _ensureSelectionValue(personalInfo.bloodGroup, personalInfo.bloodGroupList);
    if (_currentMember != null) {
      if (_currentMember!.genderId != null) {
        final id = _currentMember!.genderId;
        for (final entry in personalInfo.genderIdMap.entries) {
          if (entry.value == id) {
            personalInfo.gender.value = entry.key;
            break;
          }
        }
      }
      if (_currentMember!.maritalStatusId != null) {
        final id = _currentMember!.maritalStatusId;
        for (final entry in personalInfo.maritalStatusIdMap.entries) {
          if (entry.value == id) {
            personalInfo.maritalStatus.value = entry.key;
            break;
          }
        }
      }
      if (_currentMember!.bloodGroupId != null) {
        final id = _currentMember!.bloodGroupId;
        for (final entry in personalInfo.bloodGroupIdMap.entries) {
          if (entry.value == id) {
            personalInfo.bloodGroup.value = entry.key;
            break;
          }
        }
      }
      if (_currentMember!.relationTypeId != null) {
        final id = _currentMember!.relationTypeId;
        for (final entry in personalInfo.relationIdMap.entries) {
          if (entry.value == id) {
            personalInfo.relation.value = entry.key;
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
      if (_currentMember!.motherStateId != null && personalInfo.motherState.value.isEmpty) {
        await _resolveMotherLocations(_currentMember!);
      }
      if (_currentMember!.signId != null) {
        final id = _currentMember!.signId;
        for (final entry in personalInfo.signIdMap.entries) {
          if (entry.value == id) {
            personalInfo.sign.value = entry.key;
            break;
          }
        }
      }
    }
    _ensureSelectionValue(personalInfo.relation, personalInfo.relationList);
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
      if (_currentMember!.occupationStateId != null) {
        final id = _currentMember!.occupationStateId;
        for (final entry in workInfo.workStateIdMap.entries) {
          if (entry.value == id) {
            workInfo.workState.value = entry.key;
            await workInfo.fetchDistricts();
            break;
          }
        }
      }
      if (_currentMember!.occupationDistrictId != null) {
        final id = _currentMember!.occupationDistrictId;
        for (final entry in workInfo.workDistrictIdMap.entries) {
          if (entry.value == id) {
            workInfo.workDistrict.value = entry.key;
            await workInfo.fetchTalukas();
            break;
          }
        }
      }
      if (_currentMember!.occupationTalukaId != null) {
        final id = _currentMember!.occupationTalukaId;
        for (final entry in workInfo.workTalukaIdMap.entries) {
          if (entry.value == id) {
            workInfo.workTaluka.value = entry.key;
            await workInfo.fetchAreas();
            break;
          }
        }
      }
      if (_currentMember!.occupationAreaId != null) {
        final id = _currentMember!.occupationAreaId;
        for (final entry in workInfo.workAreaIdMap.entries) {
          if (entry.value == id) {
            workInfo.workArea.value = entry.key;
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
    _initialDropdownValues['MotherStateId'] = personalInfo.motherState.value;
    _initialDropdownValues['MotherDistrictId'] = personalInfo.motherDistrict.value;
    _initialDropdownValues['MotherTalukaId'] = personalInfo.motherTaluka.value;
    _initialDropdownValues['MotherAreaId'] = personalInfo.motherArea.value;
    _initialDropdownValues['signId'] = personalInfo.sign.value;
    _initialDropdownValues['RelationTypeId'] = personalInfo.relation.value;
    _initialDropdownValues['OccupationTypeId'] = workInfo.occupationType.value;
    _initialDropdownValues['OccupationId'] = workInfo.occupation.value;
    _initialDropdownValues['JobPositionId'] = workInfo.jobPosition.value;
    _initialDropdownValues['OccupationStateId'] = workInfo.workState.value;
    _initialDropdownValues['OccupationDistrictId'] = workInfo.workDistrict.value;
    _initialDropdownValues['OccupationTalukaId'] = workInfo.workTaluka.value;
    _initialDropdownValues['OccupationAreaId'] = workInfo.workArea.value;

    // Fix up addresses based on dropdown ID maps
    for (final addr in contactInfo.addresses) {
      if (addr.typeId != null) {
        for (final entry in contactInfo.addressTypeIdMap.entries) {
          if (entry.value == addr.typeId) {
            addr.type = entry.key;
            break;
          }
        }
      }
    }
    contactInfo.addresses.refresh();
    _initialAddressesJson = jsonEncode(contactInfo.addresses.map((e) => e.toJson()).toList());
    _initialEducationJson = jsonEncode(contactInfo.educationList.map((e) => e.toJson()).toList());

    // Trigger an update so Obx recalculates hasChanges now that snapshot is ready
    changedFormData; 
    fieldStatuses.refresh();
  }

  Future<void> _resolveMotherLocations(Member m) async {
    try {
      if (m.motherStateId != null && personalInfo.motherState.value.isEmpty) {
        String? stateName;
        for (final entry in workInfo.globalStateIdMap.entries) {
          if (entry.value == m.motherStateId) { stateName = entry.key; break; }
        }
        if (stateName == null) {
          for (final entry in workInfo.workStateIdMap.entries) {
            if (entry.value == m.motherStateId) { stateName = entry.key; break; }
          }
        }
        if (stateName != null) personalInfo.motherState.value = stateName;
      }
      
      if (personalInfo.motherState.value.isEmpty) return;

      if (m.motherDistrictId != null && personalInfo.motherDistrict.value.isEmpty) {
        final list = <String>[].obs;
        await workInfo.fetchDropdown('/district/dropdown?stateId=${m.motherStateId}', list, [], idMap: workInfo.globalDistrictIdMap);
        String? districtName;
        for (final entry in workInfo.globalDistrictIdMap.entries) {
          if (entry.value == m.motherDistrictId) { districtName = entry.key; break; }
        }
        if (districtName != null) {
          personalInfo.motherDistrict.value = districtName;
          workInfo.addressDistrictCache.putIfAbsent(personalInfo.motherState.value, () => <String>[].obs);
          if (!workInfo.addressDistrictCache[personalInfo.motherState.value]!.contains(districtName)) {
            workInfo.addressDistrictCache[personalInfo.motherState.value]!.add(districtName);
          }
        }
      }

      if (personalInfo.motherDistrict.value.isEmpty) return;

      if (m.motherTalukaId != null && personalInfo.motherTaluka.value.isEmpty) {
        final list = <String>[].obs;
        await workInfo.fetchDropdown('/taluka/dropdown?districtId=${m.motherDistrictId}', list, [], idMap: workInfo.globalTalukaIdMap);
        String? talukaName;
        for (final entry in workInfo.globalTalukaIdMap.entries) {
          if (entry.value == m.motherTalukaId) { talukaName = entry.key; break; }
        }
        if (talukaName != null) {
          personalInfo.motherTaluka.value = talukaName;
          workInfo.addressTalukaCache.putIfAbsent(personalInfo.motherDistrict.value, () => <String>[].obs);
          if (!workInfo.addressTalukaCache[personalInfo.motherDistrict.value]!.contains(talukaName)) {
            workInfo.addressTalukaCache[personalInfo.motherDistrict.value]!.add(talukaName);
          }
        }
      }

      if (personalInfo.motherTaluka.value.isEmpty) return;

      if (m.motherAreaId != null && personalInfo.motherArea.value.isEmpty) {
        final list = <String>[].obs;
        await workInfo.fetchDropdown('/Area/dropdown?talukaId=${m.motherTalukaId}', list, [], idMap: workInfo.globalAreaIdMap);
        String? areaName;
        for (final entry in workInfo.globalAreaIdMap.entries) {
          if (entry.value == m.motherAreaId) { areaName = entry.key; break; }
        }
        if (areaName != null) {
          personalInfo.motherArea.value = areaName;
          workInfo.addressAreaCache.putIfAbsent(personalInfo.motherTaluka.value, () => <String>[].obs);
          if (!workInfo.addressAreaCache[personalInfo.motherTaluka.value]!.contains(areaName)) {
            workInfo.addressAreaCache[personalInfo.motherTaluka.value]!.add(areaName);
          }
        }
      }
    } catch (e) {
      // Ignore
    } finally {
      _initialDropdownValues['MotherStateId'] = personalInfo.motherState.value;
      _initialDropdownValues['MotherDistrictId'] = personalInfo.motherDistrict.value;
      _initialDropdownValues['MotherTalukaId'] = personalInfo.motherTaluka.value;
      _initialDropdownValues['MotherAreaId'] = personalInfo.motherArea.value;
    }
  }


  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (selected.value.isNotEmpty && !list.contains(selected.value)) {
      if (list.isEmpty) return; // Wait for list to load before wiping out data
      final query = selected.value.replaceAll(' ', '').toLowerCase();
      
      String? match;
      for (final item in list) {
        if (item.replaceAll(' ', '').toLowerCase() == query) {
          match = item;
          break;
        }
      }
      
      if (match != null) {
        selected.value = match;
      } else {
        selected.value = '';
      }
    }
  }

  void submitForm({String? successMessage}) {
    final isEdit = _currentMember != null;
    bool hasListErrors = false;
    
    if (!isEdit) {
      if (addresses.isEmpty) {
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
            } else if (personalInfo.isPhotoRemoved.value) {
              formDataMap['ProfileImage'] = null;
              formDataMap['ProfilePhotoPath'] = null;
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
            formDataMap['Height'] = double.tryParse(personalInfo.heightCtrl.text) ?? 999.99;
            formDataMap['GenderId'] = getId(personalInfo.gender.value, personalInfo.genderIdMap);
            formDataMap['MaritalStatusId'] = getId(personalInfo.maritalStatus.value, personalInfo.maritalStatusIdMap);
            formDataMap['BloodGroupId'] = getId(personalInfo.bloodGroup.value, personalInfo.bloodGroupIdMap);
            formDataMap['RelationTypeId'] = getId(personalInfo.relation.value, personalInfo.relationIdMap);
            formDataMap['GotraId'] = getId(personalInfo.gotra.value, personalInfo.gotraIdMap);
            formDataMap['MotherGotraId'] = getId(personalInfo.mothersGotra.value, personalInfo.mothersGotraIdMap);
            formDataMap['MotherStateId'] = getId(personalInfo.motherState.value, workInfo.globalStateIdMap);
            formDataMap['MotherDistrictId'] = getId(personalInfo.motherDistrict.value, workInfo.globalDistrictIdMap);
            formDataMap['MotherTalukaId'] = getId(personalInfo.motherTaluka.value, workInfo.globalTalukaIdMap);
            formDataMap['MotherAreaId'] = getId(personalInfo.motherArea.value, workInfo.globalAreaIdMap);
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
            formDataMap['OccupationId'] = getId(workInfo.occupation.value, workInfo.occupationIdMap);
            formDataMap['JobPositionId'] = getId(workInfo.jobPosition.value, workInfo.jobPositionIdMap);
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
            formDataMap['OccupationAreaId'] = getId(workInfo.workArea.value, workInfo.workAreaIdMap);
            formDataMap['OccupationAddressLine1'] = workInfo.workAddressLine1Ctrl.text;
            formDataMap['OccupationAddressLine2'] = workInfo.workAddressLine2Ctrl.text;
            formDataMap['OccupationLandmark'] = workInfo.workLandmarkCtrl.text;
            formDataMap['OccupationPincode'] = workInfo.workPincodeCtrl.text;

            if (contactInfo.addresses.isNotEmpty) {
              final addr = contactInfo.addresses.firstWhere((a) => a.isPrimary, orElse: () => contactInfo.addresses.first);
              formDataMap['AddressTypeId'] = getId(addr.type, contactInfo.addressTypeIdMap) ?? addr.typeId ?? 0;
              formDataMap['AddressLine1'] = addr.line1.isEmpty ? null : addr.line1;
              formDataMap['AddressLine2'] = addr.line2.isEmpty ? null : addr.line2;
              formDataMap['Landmark'] = addr.landmark.isEmpty ? null : addr.landmark;
              formDataMap['Pincode'] = addr.pincode.isEmpty ? null : addr.pincode;
              formDataMap['AreaId'] = getId(addr.area, workInfo.globalAreaIdMap) ?? addr.areaId ?? 0;
              formDataMap['TalukaId'] = getId(addr.taluka, workInfo.globalTalukaIdMap) ?? addr.talukaId ?? 0;
            }

            if (contactInfo.educationList.isNotEmpty) {
              final edu = contactInfo.educationList.first;
              final qualId = contactInfo.educationIdMap[edu.qualification] ?? edu.qualificationId;
              if (qualId != null) formDataMap['EducationalQualificationId'] = qualId;
              formDataMap['InstitutionName'] = edu.institute.isEmpty ? null : edu.institute;
              formDataMap['YearOfPassing'] = edu.passingYear.isEmpty ? null : edu.passingYear;
              formDataMap['Percentage'] = edu.percentage;
              formDataMap['Grade'] = edu.grade.isEmpty ? null : edu.grade;
              formDataMap['Description'] = edu.description.isEmpty ? null : edu.description;
            }

            formDataMap['IsHead'] = false;
            formDataMap['IsDemised'] = false;
            formDataMap['IsActive'] = true;
            formDataMap['IsMobileVerified'] = contactInfo.mobileVerified.value;
            formDataMap['IssameAddressasMyFamilyHeadAddress'] = false;
            personalInfo.memberNoCtrl.text = generateMemberNo();
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
            } else if (personalInfo.isPhotoRemoved.value) {
              formDataMap['ProfileImage'] = null;
              formDataMap['ProfilePhotoPath'] = null;
            }
          }

          if (formDataMap.isNotEmpty) {
            // Remove any internal dummy tracking keys before sending to API
            formDataMap.removeWhere((key, value) => key.startsWith('_dummy_'));

            AppLogger.d('--- API REQUEST ---');
            AppLogger.d('URL: ${isEdit ? '/api/v1/MemberUpdateRequest/create' : '/api/v1/member/mobile/upsert'}');
            final printableMap = formDataMap.map((key, value) {
              if (value is dio.MultipartFile) {
                return MapEntry(key, 'MultipartFile(${value.filename})');
              }
              return MapEntry(key, value);
            });
            AppLogger.d('Payload: \n${JsonEncoder.withIndent('  ').convert(printableMap)}');

            final formData = dio.FormData.fromMap(formDataMap);
            final apiClient = Get.find<ApiClient>();
            final response = await apiClient.post(
              isEdit ? '/api/v1/MemberUpdateRequest/create' : '/api/v1/member/mobile/upsert',
              data: formData,
            );
            
            AppLogger.d('--- API RESPONSE ---');
            AppLogger.d(response.data?.toString() ?? 'No Response Data');
            
            if (response.data != null && response.data is Map<String, dynamic>) {
              final msg = response.data['message'] as String?;
              if (msg != null && msg.isNotEmpty) {
                successMessage = msg.tr;
              }
            }

            if (!isEdit && response.data != null && response.data is Map<String, dynamic>) {
              int? newMemberId;
              final resData = response.data['data'];
              if (resData is int) {
                newMemberId = resData;
              } else if (resData is Map<String, dynamic>) {
                newMemberId = resData['memberId'] as int? ?? resData['id'] as int?;
              }

              if (newMemberId != null) {
                int? safeGetId(String? name, Map<String, int> idMap) {
                  if (name == null || name.isEmpty) return null;
                  return idMap[name];
                }

                try {
                  final addressesPayload = {
                    'memberId': newMemberId,
                    'addresses': contactInfo.addresses.map((addr) {
                      return {
                        'memberAddressId': 0,
                        'memberId': newMemberId,
                        'addressTypeId': safeGetId(addr.type, contactInfo.addressTypeIdMap) ?? 0,
                        'stateId': safeGetId(addr.state, workInfo.globalStateIdMap) ?? 0,
                        'districtId': safeGetId(addr.district, workInfo.globalDistrictIdMap) ?? 0,
                        'talukaId': safeGetId(addr.taluka, workInfo.globalTalukaIdMap) ?? 0,
                        'areaId': safeGetId(addr.area, workInfo.globalAreaIdMap) ?? addr.areaId ?? 0,
                        'addressLine1': addr.line1,
                        'addressLine2': addr.line2,
                        'landmark': addr.landmark,
                        'pincode': addr.pincode,
                        'isPrimary': addr.isPrimary,
                        'isActive': true
                      };
                    }).toList()
                  };
                  await apiClient.post('/api/v1/member-address/upsert', data: addressesPayload);
                } catch (e) {
                  AppLogger.e('Failed to upsert addresses', e);
                }

                try {
                  final educationsPayload = {
                    'memberId': newMemberId,
                    'educations': contactInfo.educationList.map((edu) {
                      return {
                        'memberEducationId': 0,
                        'memberId': newMemberId,
                        'educationalQualificationId': contactInfo.educationIdMap[edu.qualification] ?? edu.qualificationId ?? 0,
                        'description': edu.description,
                        'institutionName': edu.institute,
                        'yearOfPassing': int.tryParse(edu.passingYear) ?? 0,
                        'percentage': double.tryParse(edu.percentage) ?? 0,
                        'grade': edu.grade,
                        'isHighestQualification': edu.isHighest,
                        'isActive': true
                      };
                    }).toList()
                  };
                  await apiClient.post('/api/v1/MemberEducation/upsert', data: educationsPayload);
                } catch (e) {
                  AppLogger.e('Failed to upsert educations', e);
                }
              }
            }

            if (isEdit && editRequestCommentCtrl.text.trim().isNotEmpty) {
              try {
                await apiClient.post(
                  '/api/v1/MemberUpdateRequest/authorized-comment',
                  data: {
                    'memberId': _currentMember!.memberId,
                    'profileUpdateComment': editRequestCommentCtrl.text.trim(),
                    'rejectedReasonCommentByAdmin': null
                  },
                );
              } catch (e, stack) {
                AppLogger.e('Failed to send edit request comment', e, stack);
              }
            }
          } else if (isEdit && editRequestCommentCtrl.text.trim().isNotEmpty) {
            final apiClient = Get.find<ApiClient>();
            try {
              await apiClient.post(
                '/api/v1/MemberUpdateRequest/authorized-comment',
                data: {
                  'memberId': _currentMember!.memberId,
                  'profileUpdateComment': editRequestCommentCtrl.text.trim(),
                  'rejectedReasonCommentByAdmin': null
                },
              );
            } catch (e, stack) {
              AppLogger.e('Failed to send edit request comment', e, stack);
            }
          }

          Get.snackbar(
            LK.success.tr,
            isEdit ? LK.editProfileRequestSent.tr : LK.memberAddedSuccessfully.tr,
            backgroundColor: AppColors.green,
            colorText: AppColors.white,
          );
          
          await Future<void>.delayed(const Duration(milliseconds: 1500));
          await Get.offAllNamed<void>(AppRouter.home);
        } catch (e, stack) {
          AppLogger.e('Submit form error', e, stack);
          String errorMessage = LK.unexpectedError.tr;
          if (e is Failure) {
            errorMessage = e.message;
          } else if (e is dio.DioException) {
            AppLogger.e('--- DIO ERROR DETAILS ---');
            AppLogger.e('Status Code: ${e.response?.statusCode}');
            AppLogger.e('Response Data: ${e.response?.data}');
          }
          Get.snackbar(
            LK.error.tr,
            errorMessage,
            backgroundColor: AppColors.red,
            colorText: AppColors.white,
          );
        } finally {
          personalInfo.uploadProgress.value = 0.0;
        }
      });
    } else {
      showListErrors.value = true;
      Get.snackbar(
        LK.errorValidation.tr,
        LK.pleaseFillRequiredFields.tr,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }
}
