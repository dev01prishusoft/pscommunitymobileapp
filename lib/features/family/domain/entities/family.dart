import 'package:pscommunitymobileapp/core/config/app_environment.dart';

class FamilyMember {
  FamilyMember({
    required this.id,
    required this.name,
    required this.isHead,
    required this.gender,
    required this.relation,
    required this.maritalStatus,
    required this.occupation,
    this.mobileNo,
    this.profileUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final dynamic rawId =
        json['memberId'] ?? json['MemberId'] ?? json['id'] ?? json['Id'];
    return FamilyMember(
      id: rawId?.toString() ?? '0',
      name: json['name'] as String? ?? '',
      isHead: json['isHead'] as bool? ?? false,
      gender: json['gender'] as String? ?? '',
      relation: json['relationWithHead'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      mobileNo: (json['mobileNo'] ?? json['MobileNo'] ?? json['mobile_no'])
          ?.toString(),
      profileUrl:
          json['profileUrl'] as String? ??
          json['profilePhotoFullUrl'] as String? ??
          json['memberProfileUrl'] as String?,
    );
  }
  final String id;
  final String name;
  final bool isHead;
  final String gender;
  final String relation;
  final String maritalStatus;
  final String occupation;
  final String? mobileNo;
  final String? profileUrl;

  String? get profileImageUrl {
    if (profileUrl == null || profileUrl!.isEmpty) return null;
    if (profileUrl!.startsWith('http')) return profileUrl;
    final baseUrl = AppEnvironment.I.apiBaseUrl;
    return profileUrl!.startsWith('/')
        ? '$baseUrl$profileUrl'
        : '$baseUrl/$profileUrl';
  }
}

class Family {
  Family({required this.familyName, required this.members});

  factory Family.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] != null
        ? (json['members'] as List<dynamic>)
              .map((i) => FamilyMember.fromJson(i as Map<String, dynamic>))
              .toList()
        : <FamilyMember>[];
    final Set<String> seenIds = {};
    final List<FamilyMember> uniqueMembers = [];
    for (var member in rawMembers) {
      if (!seenIds.contains(member.id)) {
        seenIds.add(member.id);
        uniqueMembers.add(member);
      }
    }

    String finalFamilyName = json['name'] as String? ?? '';
    try {
      final head = uniqueMembers.firstWhere((m) => m.isHead);
      if (head.name.isNotEmpty) {
        finalFamilyName = head.name;
      }
    } catch (_) {}

    return Family(
      familyName: finalFamilyName,
      members: uniqueMembers,
    );
  }
  final String familyName;
  final List<FamilyMember> members;
}
