class OccupationItem {
  OccupationItem({
    required this.id,
    this.memberId,
    required this.name,
    this.logoUrl,
    this.count,
    this.iconKey,
    this.memberName,
    this.occupationTypeId,
    this.occupationType,
    this.companyName,
    this.businessAddress,
    this.mobile,
    this.description,
    this.isActive = true,
  });

  factory OccupationItem.fromJson(Map<String, dynamic> json) {
    return OccupationItem(
      id: json['occupationId'] as int? ?? json['id'] as int? ?? 0,
      memberId: json['memberId'] as int?,
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      count: json['memberCount'] as int? ?? json['count'] as int?,
      iconKey: json['iconKey'] as String?,
      memberName: json['memberName'] as String?,
      occupationTypeId: json['occupationTypeId'] as int? ??
          int.tryParse(json['occupationTypeId']?.toString() ?? '') ??
          (json['occupationType'] is int ? json['occupationType'] as int : null) ??
          int.tryParse(json['OccupationTypeId']?.toString() ?? ''),
      occupationType: json['occupationTypeName'] as String? ??
          (json['occupationType'] is String ? json['occupationType'] as String : null) ??
          json['OccupationTypeName'] as String?,
      companyName: json['companyName'] as String?,
      businessAddress: json['businessAddress'] as String?,
      mobile: json['mobileNo'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  final int id;
  final int? memberId;
  final String name;
  final String? logoUrl;
  final int? count;
  final String? iconKey;
  final String? memberName;
  final int? occupationTypeId;
  final String? occupationType;
  final String? companyName;
  final String? businessAddress;
  final String? mobile;
  final String? description;
  final bool isActive;
}
