class MarriageProfile {
  MarriageProfile({
    required this.memberId,
    required this.name,
    required this.age,
    required this.occupation,
    required this.gotra,
    required this.location,
    required this.lookingForMarriage,
    required this.gender,
  });

  factory MarriageProfile.fromJson(Map<String, dynamic> json) {
    return MarriageProfile(
      memberId: json['memberId'] as int? ?? 0,
      name: json['fullName'] as String? ?? json['name'] as String? ?? '',
      age: (json['age'] ?? '').toString(),
      occupation:
          json['occupationTypeName'] as String? ??
          json['occupation'] as String? ??
          '',
      gotra:
          json['gotraName'] as String? ??
          json['gotra'] as String? ??
          json['gotra_name'] as String? ??
          json['Gotra'] as String? ??
          '',
      location:
          json['areaName'] as String? ?? json['location'] as String? ?? '',
      lookingForMarriage:
          json['isLookingforMarriage'] as bool? ??
          json['lookingForMarriage'] as bool? ??
          false,
      gender: json['genderName'] as String? ?? json['gender'] as String? ?? '',
    );
  }
  final int memberId;
  final String name;
  final String age;
  final String occupation;
  final String gotra;
  final String location;
  final bool lookingForMarriage;
  final String gender;
}
