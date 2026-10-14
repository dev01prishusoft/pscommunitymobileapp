import 'package:pscommunitymobileapp/core/constants/app_environment.dart';

enum GenderCategory { male, female, other }

class FamilyTreeResponse {
  FamilyTreeResponse({
    required this.statusCode,
    required this.succeeded,
    required this.message,
    required this.data,
  });

  factory FamilyTreeResponse.fromJson(Map<String, dynamic> json) {
    return FamilyTreeResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      succeeded: json['succeeded'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? FamilyTreeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final int statusCode;
  final bool succeeded;
  final String message;
  final FamilyTreeData? data;
}

class FamilyTreeData {
  FamilyTreeData({
    required this.familyId,
    required this.familyName,
    required this.headMemberId,
    required this.totalMembers,
    required this.head,
    this.lifePartner,
    this.flatNodes = const [],
  });

  factory FamilyTreeData.fromJson(Map<String, dynamic> json) {
    FamilyTreeNode? headNode;
    if (json['head'] != null) {
      headNode = FamilyTreeNode.fromJson(json['head'] as Map<String, dynamic>);
    } else if (json['root'] != null) {
      headNode = FamilyTreeNode.fromJson(json['root'] as Map<String, dynamic>);
    }

    FamilyTreeNode? partnerNode;
    if (json['lifePartner'] != null) {
      partnerNode = FamilyTreeNode.fromJson(
        json['lifePartner'] as Map<String, dynamic>,
      );
    }

    final flatList = <FamilyTreeNode>[];
    if (json['flatNodes'] is List) {
      for (final item in json['flatNodes'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          flatList.add(FamilyTreeNode.fromJson(item));
        }
      }
    }

    return FamilyTreeData(
      familyId: json['familyId'] as int? ?? 0,
      familyName: json['familyName'] as String? ?? '',
      headMemberId: json['headMemberId'] as int? ?? 0,
      totalMembers: json['totalMembers'] as int? ?? 0,
      head: headNode,
      lifePartner: partnerNode,
      flatNodes: flatList,
    );
  }

  final int familyId;
  final String familyName;
  final int headMemberId;
  final int totalMembers;
  final FamilyTreeNode? head;
  final FamilyTreeNode? lifePartner;
  final List<FamilyTreeNode> flatNodes;

  int get maxGenerations {
    if (head == null) return 0;
    return head!.calculateGenerations();
  }
}

class FamilyTreeNode {
  FamilyTreeNode({
    required this.memberId,
    this.familyMemberId,
    required this.memberNo,
    this.firstName,
    this.middleName,
    this.lastName,
    required this.fullName,
    this.genderId,
    this.genderEnglishName,
    this.genderName,
    this.relationTypeId,
    this.relationTypeName,
    this.relationTypeCode,
    this.isHead = false,
    this.isLifePartner = false,
    this.relatedToMemberId,
    this.partnerMemberId,
    this.partner,
    this.profilePhotoUrl,
    this.isDemised = false,
    this.demisedDate,
    this.dateOfBirth,
    this.mobileNo,
    this.children = const [],
  });

  factory FamilyTreeNode.fromJson(Map<String, dynamic> json) {
    FamilyTreeNode? partnerNode;
    if (json['partner'] != null && json['partner'] is Map<String, dynamic>) {
      partnerNode = FamilyTreeNode.fromJson(
        json['partner'] as Map<String, dynamic>,
      );
    }

    final childNodes = <FamilyTreeNode>[];
    if (json['children'] is List) {
      for (final c in json['children'] as List<dynamic>) {
        if (c is Map<String, dynamic>) {
          childNodes.add(FamilyTreeNode.fromJson(c));
        }
      }
    }

    return FamilyTreeNode(
      memberId: json['memberId'] as int? ?? 0,
      familyMemberId: json['familyMemberId'] as int?,
      memberNo: json['memberNo']?.toString() ?? '',
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      fullName: json['fullName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      genderId: json['genderId'] as int?,
      genderEnglishName: json['genderEnglishName'] as String?,
      genderName: json['genderName'] as String?,
      relationTypeId: json['relationTypeId'] as int?,
      relationTypeName: json['relationTypeName'] as String?,
      relationTypeCode: json['relationTypeCode'] as String?,
      isHead: json['isHead'] as bool? ?? false,
      isLifePartner: json['isLifePartner'] as bool? ?? false,
      relatedToMemberId: json['relatedToMemberId'] as int?,
      partnerMemberId: json['partnerMemberId'] as int?,
      partner: partnerNode,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isDemised: json['isDemised'] as bool? ?? false,
      demisedDate: json['demisedDate']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      mobileNo: json['mobileNo']?.toString(),
      children: childNodes,
    );
  }

  final int memberId;
  final int? familyMemberId;
  final String memberNo;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String fullName;
  final int? genderId;
  final String? genderEnglishName;
  final String? genderName;
  final int? relationTypeId;
  final String? relationTypeName;
  final String? relationTypeCode;
  final bool isHead;
  final bool isLifePartner;
  final int? relatedToMemberId;
  final int? partnerMemberId;
  final FamilyTreeNode? partner;
  final String? profilePhotoUrl;
  final bool isDemised;
  final String? demisedDate;
  final String? dateOfBirth;
  final String? mobileNo;
  final List<FamilyTreeNode> children;

  String? get profileImageUrl {
    if (profilePhotoUrl == null || profilePhotoUrl!.isEmpty) return null;
    if (profilePhotoUrl!.startsWith('http')) return profilePhotoUrl;
    final baseUrl = AppEnvironment.I.apiBaseUrl;
    return profilePhotoUrl!.startsWith('/')
        ? '$baseUrl$profilePhotoUrl'
        : '$baseUrl/$profilePhotoUrl';
  }

  bool get isMale {
    final g = (genderEnglishName ?? genderName ?? '').toLowerCase();
    if (g.contains('male') && !g.contains('female')) return true;
    return genderId == 1;
  }

  bool get isFemale {
    final g = (genderEnglishName ?? genderName ?? '').toLowerCase();
    if (g.contains('female')) return true;
    return genderId == 6 || genderId == 2;
  }

  bool get isOther => !isMale && !isFemale;

  GenderCategory get genderCategory {
    if (isMale) return GenderCategory.male;
    if (isFemale) return GenderCategory.female;
    return GenderCategory.other;
  }

  String get initials {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  int calculateGenerations() {
    if (children.isEmpty) return 1;
    int maxChildGen = 0;
    for (final child in children) {
      final gen = child.calculateGenerations();
      if (gen > maxChildGen) {
        maxChildGen = gen;
      }
    }
    return 1 + maxChildGen;
  }
}
