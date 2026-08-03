class CommitteeDetail {
  CommitteeDetail({
    required this.name,
    this.parentName,
    required this.description,
    required this.roles,
    required this.members,
  });

  factory CommitteeDetail.fromJson(Map<String, dynamic> json) {
    return CommitteeDetail(
      name: json['name'] as String? ?? '',
      parentName: json['parentName'] as String?,
      description: json['description'] as String? ?? '',
      roles: (json['roles'] as List? ?? [])
          .map((e) => CommitteeRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List? ?? [])
          .map((e) => CommitteeMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final String name;
  final String? parentName;
  final String description;
  final List<CommitteeRole> roles;
  final List<CommitteeMember> members;

  CommitteeDetail copyWith({
    String? name,
    String? parentName,
    String? description,
    List<CommitteeRole>? roles,
    List<CommitteeMember>? members,
  }) {
    return CommitteeDetail(
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      description: description ?? this.description,
      roles: roles ?? this.roles,
      members: members ?? this.members,
    );
  }
}

class CommitteeRole {
  CommitteeRole({
    required this.roleName,
    required this.roleTypeName,
    required this.memberCount,
  });

  factory CommitteeRole.fromJson(Map<String, dynamic> json) {
    return CommitteeRole(
      roleName: json['committeeRoleName'] as String? ?? '',
      roleTypeName: json['committeeRoleTypeName'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
    );
  }
  final String roleName;
  final String roleTypeName;
  final int memberCount;
}

class CommitteeMember {
  CommitteeMember({
    required this.memberId,
    required this.name,
    required this.roleName,
    required this.roleTypeName,
    this.committeeRoleId,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.reportsToName,
  });

  factory CommitteeMember.fromJson(Map<String, dynamic> json) {
    return CommitteeMember(
      memberId:
          int.tryParse(
            (json['memberId'] ?? json['id'] ?? json['Id'] ?? 0).toString(),
          ) ??
          0,
      name: json['name'] as String? ?? json['memberName'] as String? ?? '',
      roleName: json['committeeRoleName'] as String? ?? '',
      roleTypeName: json['committeeRoleTypeName'] as String? ?? '',
      committeeRoleId: json['committeeRoleId'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      imageUrl: json['imageUrl'] as String?,
      reportsToName: json['reportsToMemberName'] as String? ?? json['reportsToName'] as String? ?? json['reportsTo'] as String?,
    );
  }
  final int memberId;
  final String name;
  final String roleName;
  final String roleTypeName;
  final int? committeeRoleId;
  final String? startDate;
  final String? endDate;
  final String? imageUrl;
  final String? reportsToName;
}
