import 'package:pscommunitymobileapp/core/config/app_environment.dart';

class Member {
  Member({
    required this.memberId,
    this.memberNo,
    required this.firstName,
    this.firstNameEnglish,
    this.middleName,
    required this.lastName,
    this.lastNameEnglish,
    this.fullNameSearchText,
    this.dateOfBirth,
    this.dateOfBirthTime,
    this.weight,
    this.height,
    this.mobileNo,
    this.secondaryMobile,
    this.emailAddress,
    this.genderId,
    this.genderName,
    this.maritalStatusId,
    this.maritalStatusName,
    this.bloodGroupId,
    this.bloodGroupName,
    this.isLookingforMarriage,
    this.educationName,
    this.jobPositionName,
    this.otherJobPosition,
    this.monthlyIncome,
    this.isOwnLand,
    this.isOwnHouse,
    this.hasTwoWheeler,
    this.hasFourWheeler,
    this.emergencyContactNo,
    this.emergencyContactName,
    this.entryPersonMobileNo,
    this.facebookUrl,
    this.whatsappUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.profilePhotoFullUrl,
    this.gotraName,
    this.motherFatherName,
    this.motherStateName,
    this.motherDistrictName,
    this.motherTalukaName,
    this.motherAreaName,
    this.occupationTypeName,
    this.occupationName,
    this.otherOccupation,
    this.occupationDescription,
    this.companyName,
    this.businessName,
    this.occupationTalukaName,
    this.occupationDistrictName,
    this.occupationStateName,
    this.occupationAreaName,
    this.occupationAddressLine1,
    this.occupationAddressLine2,
    this.occupationLandmark,
    this.occupationPincode,
    this.stateId,
    this.districtId,
    this.talukaId,
    this.areaId,
    this.occupationStateId,
    this.occupationDistrictId,
    this.occupationTalukaId,
    this.occupationAreaId,
    this.familyId,
    this.apiAge,
    this.isHead,
    this.relatedToMemberName,
    this.relationTypeId,
    this.gotraId,
    this.motherGotraId,
    this.motherStateId,
    this.motherDistrictId,
    this.motherTalukaId,
    this.motherAreaId,
    this.signId,
    this.signName,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? getString(
      String key, [
      String? fallbackKey,
      String? fallbackKey2,
      String? fallbackKey3,
    ]) {
      final val =
          json[key] ??
          json[fallbackKey] ??
          json[fallbackKey2] ??
          json[fallbackKey3];
      if (val == null) return null;
      final s = val.toString().trim();
      return s.isEmpty ? null : s;
    }

    final String fullName = getString('memberName', 'name', 'fullName') ?? '';
    final List<String> nameParts = fullName.split(' ');
    final String fallbackFirst = nameParts.isNotEmpty ? nameParts[0] : '';
    final String fallbackLast = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';
    final int fallbackAge = (json['age'] as num?)?.toInt() ?? 0;

    final String? profilePhoto = getString(
      'profilePhotoFullUrl',
      'memberProfileUrl',
      'profileUrl',
    );
    String? fullProfileUrl = profilePhoto;
    if (fullProfileUrl != null &&
        fullProfileUrl.isNotEmpty &&
        !fullProfileUrl.startsWith('http')) {
      final baseUrl = AppEnvironment.I.apiBaseUrl;
      fullProfileUrl = fullProfileUrl.startsWith('/')
          ? '$baseUrl$fullProfileUrl'
          : '$baseUrl/$fullProfileUrl';
    }

    return Member(
      memberId: (json['memberId'] ?? json['id']) as int? ?? 0,
      memberNo: getString('memberNo'),
      firstName: getString('firstName') ?? fallbackFirst,
      firstNameEnglish: getString('firstNameEnglish'),
      middleName: getString('middleName'),
      lastName: getString('lastName') ?? fallbackLast,
      lastNameEnglish: getString('lastNameEnglish'),
      fullNameSearchText: getString('fullNameSearchText'),
      dateOfBirth: getString('dateOfBirth'),
      dateOfBirthTime: getString('dateOfBirthTime'),
      apiAge: fallbackAge,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      mobileNo: getString('mobileNo'),
      secondaryMobile: getString('secondaryMobile'),
      emailAddress: getString('emailAddress'),
      genderId: (json['genderId'] ?? json['GenderId']) as int?,
      genderName: getString('genderName', 'gender'),
      maritalStatusId: (json['maritalStatusId'] ?? json['MaritalStatusId']) as int?,
      maritalStatusName: getString(
        'maritalStatusName',
        'maritalStatus',
        'marritalStatus',
      ),
      bloodGroupId: (json['bloodGroupId'] ?? json['BloodGroupId']) as int?,
      bloodGroupName: getString('bloodGroupName', 'bloodGroup', 'BloodGroup'),
      isLookingforMarriage:
          (json['isLookingforMarriage'] ??
                  json['LookingforMarriage'] ??
                  json['isLookingForMarriage'])
              as bool?,
      educationName: getString('educationName', 'educationalQualification', 'education'),
      jobPositionName: getString('jobPositionName'),
      otherJobPosition: getString('otherJobPosition'),
      monthlyIncome: (json['monthlyIncome'] as num?)?.toInt(),
      isOwnLand: json['isOwnLand'] as bool?,
      isOwnHouse: json['isOwnHouse'] as bool?,
      hasTwoWheeler: json['hasTwoWheeler'] as bool?,
      hasFourWheeler: json['hasFourWheeler'] as bool?,
      emergencyContactNo: getString('emergencyContactNo'),
      emergencyContactName: getString('emergencyContactName'),
      entryPersonMobileNo: getString('entryPersonMobileNo'),
      facebookUrl: getString('facebookUrl'),
      whatsappUrl: getString('whatsappUrl'),
      instagramUrl: getString('instagramUrl'),
      twitterUrl: getString('twitterUrl'),
      profilePhotoFullUrl: fullProfileUrl,
      gotraName: getString('gotraName', 'gotra', 'gotra_name', 'Gotra'),
      motherFatherName: getString('motherFatherName', 'MotherFatherName'),
      motherStateName: getString('motherStateName', 'MotherStateName'),
      motherDistrictName: getString('motherDistrictName', 'MotherDistrictName'),
      motherTalukaName: getString('motherTalukaName', 'MotherTalukaName'),
      motherAreaName: getString('motherAreaName', 'MotherAreaName'),
      occupationTypeName: getString('occupationTypeName'),
      occupationName: getString('occupationName', 'occupation'),
      otherOccupation: getString('otherOccupation'),
      occupationDescription: getString('occupationDescription'),
      companyName: getString('companyName'),
      businessName: getString('businessName'),
      occupationTalukaName: getString(
        'occupationTalukaName',
        'memberTalukaName',
        'talukaName',
      ),
      occupationDistrictName: getString(
        'occupationDistrictName',
        'districtName',
      ),
      occupationStateName: getString('occupationStateName', 'stateName'),
      occupationAreaName: getString(
        'occupationAreaName',
        'memberAreaName',
        'areaName',
      ),
      occupationAddressLine1: getString('occupationAddressLine1'),
      occupationAddressLine2: getString('occupationAddressLine2'),
      occupationLandmark: getString('occupationLandmark'),
      occupationPincode: getString('occupationPincode'),
      stateId: json['stateId'] as int?,
      districtId: json['districtId'] as int?,
      talukaId: json['talukaId'] as int?,
      areaId: json['areaId'] as int?,
      occupationStateId: json['occupationStateId'] as int?,
      occupationDistrictId: json['occupationDistrictId'] as int?,
      occupationTalukaId: json['occupationTalukaId'] as int?,
      occupationAreaId: json['occupationAreaId'] as int?,
      familyId: json['familyId'] as int?,
      isHead: json['isHead'] as bool?,
      relatedToMemberName: getString('relatedToMemberName'),
      relationTypeId: json['relationTypeId'] as int?,
      gotraId: json['gotraId'] as int?,
      motherGotraId: json['motherGotraId'] as int?,
      motherStateId: (json['motherStateId'] ?? json['MotherStateId']) as int?,
      motherDistrictId: (json['motherDistrictId'] ?? json['MotherDistrictId']) as int?,
      motherTalukaId: (json['motherTalukaId'] ?? json['MotherTalukaId']) as int?,
      motherAreaId: (json['motherAreaId'] ?? json['MotherAreaId']) as int?,
      signId: (json['signId'] ?? json['SignId']) as int?,
      signName: getString('signName', 'SignName'),
    );
  }
  final int memberId;
  final String? memberNo;
  final String firstName;
  final String? firstNameEnglish;
  final String? middleName;
  final String lastName;
  final String? lastNameEnglish;
  final String? fullNameSearchText;
  final String? dateOfBirth;
  final String? dateOfBirthTime;
  final double? weight;
  final double? height;
  final String? mobileNo;
  final String? secondaryMobile;
  final String? emailAddress;
  final int? genderId;
  final String? genderName;
  final int? maritalStatusId;
  final String? maritalStatusName;
  final int? bloodGroupId;
  final String? bloodGroupName;
  final bool? isLookingforMarriage;
  final String? educationName;
  final String? jobPositionName;
  final String? otherJobPosition;
  final int? monthlyIncome;
  final bool? isOwnLand;
  final bool? isOwnHouse;
  final bool? hasTwoWheeler;
  final bool? hasFourWheeler;
  final String? emergencyContactNo;
  final String? emergencyContactName;
  final String? entryPersonMobileNo;
  final String? facebookUrl;
  final String? whatsappUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? profilePhotoFullUrl;
  final String? gotraName;
  final String? motherFatherName;
  final String? motherStateName;
  final String? motherDistrictName;
  final String? motherTalukaName;
  final String? motherAreaName;
  final String? occupationTypeName;
  final String? occupationName;
  final String? otherOccupation;
  final String? occupationDescription;
  final String? companyName;
  final String? businessName;
  final String? occupationTalukaName;
  final String? occupationDistrictName;
  final String? occupationStateName;
  final String? occupationAreaName;
  final String? occupationAddressLine1;
  final String? occupationAddressLine2;
  final String? occupationLandmark;
  final String? occupationPincode;
  final int? stateId;
  final int? districtId;
  final int? talukaId;
  final int? areaId;
  final int? occupationStateId;
  final int? occupationDistrictId;
  final int? occupationTalukaId;
  final int? occupationAreaId;
  final int? familyId;
  final int? apiAge;
  final bool? isHead;
  final String? relatedToMemberName;
  final int? relationTypeId;
  final int? gotraId;
  final int? motherGotraId;
  final int? motherStateId;
  final int? motherDistrictId;
  final int? motherTalukaId;
  final int? motherAreaId;
  final int? signId;
  final String? signName;

  String get fullName =>
      '$firstName ${middleName ?? ''} $lastName'.replaceFirst('  ', ' ').trim();
  String get name => fullName;
  String get gender => genderName ?? '';
  String get occupation => occupationName ?? occupationTypeName ?? '';
  String get area => occupationAreaName ?? '';
  String get gotra => gotraName ?? '';
  int get age {
    if (dateOfBirth == null) return apiAge ?? 0;
    try {
      final dob = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int ageCount = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        ageCount--;
      }
      return ageCount;
    } catch (_) {
      return apiAge ?? 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberNo': memberNo,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'dateOfBirthTime': dateOfBirthTime,
      'weight': weight,
      'height': height,
      'mobileNo': mobileNo,
      'secondaryMobile': secondaryMobile,
      'emailAddress': emailAddress,
      'genderName': genderName,
      'maritalStatusName': maritalStatusName,
      'bloodGroupName': bloodGroupName,
      'isLookingforMarriage': isLookingforMarriage,
      'educationName': educationName,
      'gotraName': gotraName,
      'jobPositionName': jobPositionName,
      'companyName': companyName,
      'businessName': businessName,
      'monthlyIncome': monthlyIncome,
      'occupationStateName': occupationStateName,
      'occupationDistrictName': occupationDistrictName,
      'occupationTalukaName': occupationTalukaName,
      'occupationAreaName': occupationAreaName,
      'occupationAddressLine1': occupationAddressLine1,
      'occupationAddressLine2': occupationAddressLine2,
      'stateId': stateId,
      'districtId': districtId,
      'talukaId': talukaId,
      'areaId': areaId,
      // Add other fields if necessary
    };
  }
}
