class Member {
  final int memberId;
  final String? memberNo;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? fullNameSearchText;
  final String? dateOfBirth;
  final String? dateOfBirthTime;
  final int? weight;
  final int? height;
  final String? mobileNo;
  final String? secondaryMobile;
  final String? emailAddress;
  final String? genderName;
  final String? maritalStatusName;
  final String? bloodGroupName;
  final bool? isLookingforMarriage;
  final String? jobPositionName;
  final String? otherJobPosition;
  final int? monthlyIncome;
  final bool? isOwnLand;
  final bool? isOwnHouse;
  final bool? hasTwoWheeler;
  final bool? hasFourWheeler;
  final String? emergencyContactNo;
  final String? emergencyContactName;
  final String? facebookUrl;
  final String? whatsappUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? profilePhotoFullUrl;
  final String? gotraName;
  final String? motherFatherName;
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
  final int? familyId;
  final int? apiAge;

  const Member({
    required this.memberId,
    this.memberNo,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.fullNameSearchText,
    this.dateOfBirth,
    this.dateOfBirthTime,
    this.weight,
    this.height,
    this.mobileNo,
    this.secondaryMobile,
    this.emailAddress,
    this.genderName,
    this.maritalStatusName,
    this.bloodGroupName,
    this.isLookingforMarriage,
    this.jobPositionName,
    this.otherJobPosition,
    this.monthlyIncome,
    this.isOwnLand,
    this.isOwnHouse,
    this.hasTwoWheeler,
    this.hasFourWheeler,
    this.emergencyContactNo,
    this.emergencyContactName,
    this.facebookUrl,
    this.whatsappUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.profilePhotoFullUrl,
    this.gotraName,
    this.motherFatherName,
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
    this.familyId,
    this.apiAge,
  });

  String get fullName => '$firstName ${middleName ?? ''} $lastName'.replaceFirst('  ', ' ').trim();
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
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        ageCount--;
      }
      return ageCount;
    } catch (_) {
      return apiAge ?? 0;
    }
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    String? getString(String key, [String? fallbackKey, String? fallbackKey2, String? fallbackKey3]) {
      final val = json[key] ?? json[fallbackKey] ?? json[fallbackKey2] ?? json[fallbackKey3];
      if (val == null) return null;
      final s = val.toString().trim();
      return s.isEmpty ? null : s;
    }

    final String fullName = getString('memberName', 'name', 'fullName') ?? '';
    final List<String> nameParts = fullName.split(' ');
    final String fallbackFirst = nameParts.isNotEmpty ? nameParts[0] : '';
    final String fallbackLast = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final int fallbackAge = (json['age'] as num?)?.toInt() ?? 0;

    return Member(
      memberId: (json['memberId'] ?? json['id']) as int? ?? 0,
      memberNo: getString('memberNo'),
      firstName: getString('firstName') ?? fallbackFirst,
      middleName: getString('middleName'),
      lastName: getString('lastName') ?? fallbackLast,
      fullNameSearchText: getString('fullNameSearchText'),
      dateOfBirth: getString('dateOfBirth'),
      dateOfBirthTime: getString('dateOfBirthTime'),
      apiAge: fallbackAge,
      weight: (json['weight'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      mobileNo: getString('mobileNo'),
      secondaryMobile: getString('secondaryMobile'),
      emailAddress: getString('emailAddress'),
      genderName: getString('genderName', 'gender'),
      maritalStatusName: getString('maritalStatusName', 'maritalStatus', 'marritalStatus'),
      bloodGroupName: getString('bloodGroupName'),
      isLookingforMarriage: json['isLookingforMarriage'] as bool?,
      jobPositionName: getString('jobPositionName'),
      otherJobPosition: getString('otherJobPosition'),
      monthlyIncome: (json['monthlyIncome'] as num?)?.toInt(),
      isOwnLand: json['isOwnLand'] as bool?,
      isOwnHouse: json['isOwnHouse'] as bool?,
      hasTwoWheeler: json['hasTwoWheeler'] as bool?,
      hasFourWheeler: json['hasFourWheeler'] as bool?,
      emergencyContactNo: getString('emergencyContactNo'),
      emergencyContactName: getString('emergencyContactName'),
      facebookUrl: getString('facebookUrl'),
      whatsappUrl: getString('whatsappUrl'),
      instagramUrl: getString('instagramUrl'),
      twitterUrl: getString('twitterUrl'),
      profilePhotoFullUrl: getString('profilePhotoFullUrl'),
      gotraName: getString('gotraName', 'gotra'),
      motherFatherName: getString('motherFatherName'),
      occupationTypeName: getString('occupationTypeName'),
      occupationName: getString('occupationName', 'occupation'),
      otherOccupation: getString('otherOccupation'),
      occupationDescription: getString('occupationDescription'),
      companyName: getString('companyName'),
      businessName: getString('businessName'),
      occupationTalukaName: getString('occupationTalukaName', 'memberTalukaName', 'talukaName'),
      occupationDistrictName: getString('occupationDistrictName', 'districtName'),
      occupationStateName: getString('occupationStateName', 'stateName'),
      occupationAreaName: getString('occupationAreaName', 'memberAreaName', 'areaName'),
      occupationAddressLine1: getString('occupationAddressLine1'),
      occupationAddressLine2: getString('occupationAddressLine2'),
      occupationLandmark: getString('occupationLandmark'),
      occupationPincode: getString('occupationPincode'),
      familyId: json['familyId'] as int?,
    );
  }
}
