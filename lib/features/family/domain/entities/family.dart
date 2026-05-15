class FamilyMember {
  final String id;
  final String name;
  final bool isHead;
  final String gender;
  final String relation;
  final String maritalStatus;
  final String occupation;
  final String? mobileNo;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.isHead,
    required this.gender,
    required this.relation,
    required this.maritalStatus,
    required this.occupation,
    this.mobileNo,
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
      mobileNo: (json['mobileNo'] ?? json['MobileNo'] ?? json['mobile_no'])?.toString(),
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
    final rawMembers = json['members'] != null
        ? (json['members'] as List<dynamic>).map((i) => FamilyMember.fromJson(i as Map<String, dynamic>)).toList()
        : <FamilyMember>[];
    
    // Filter duplicates by member ID
    final Set<String> seenIds = {};
    final List<FamilyMember> uniqueMembers = [];
    for (var member in rawMembers) {
      if (!seenIds.contains(member.id)) {
        seenIds.add(member.id);
        uniqueMembers.add(member);
      }
    }

    return Family(
      familyName: json['name'] as String? ?? '',
      members: uniqueMembers,
    );
  }
}
