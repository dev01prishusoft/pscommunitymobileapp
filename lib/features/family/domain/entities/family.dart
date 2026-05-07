class FamilyMember {
  final String id;
  final String name;
  final bool isHead;
  final String gender;
  final String relation;
  final String maritalStatus;
  final String occupation;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.isHead,
    required this.gender,
    required this.relation,
    required this.maritalStatus,
    required this.occupation,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['memberId'] ?? json['MemberId'] ?? json['id'] ?? json['Id'];
    return FamilyMember(
      id: rawId?.toString() ?? '0',
      name: json['name'] as String? ?? '',
      isHead: json['isHead'] as bool? ?? false,
      gender: json['gender'] as String? ?? '',
      relation: json['relationWithHead'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
    );
  }
}

class Family {
  final String familyName;
  final List<FamilyMember> members;

  const Family({
    required this.familyName,
    required this.members,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      familyName: json['name'] as String? ?? '',
      members: json['members'] != null
          ? (json['members'] as List<dynamic>).map((i) => FamilyMember.fromJson(i as Map<String, dynamic>)).toList()
          : const [],
    );
  }
}
