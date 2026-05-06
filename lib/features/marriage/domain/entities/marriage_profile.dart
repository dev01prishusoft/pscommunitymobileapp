class MarriageProfile {
  final String name;
  final String age;
  final String occupation;
  final String gotra;
  final String location;
  final bool lookingForMarriage;
  final String gender;

  const MarriageProfile({
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
      name: json['name'] as String? ?? '',
      age: json['age'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      gotra: json['gotra'] as String? ?? '',
      location: json['location'] as String? ?? '',
      lookingForMarriage: json['lookingForMarriage'] as bool? ?? false,
      gender: json['gender'] as String? ?? '',
    );
  }
}
