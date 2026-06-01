class OccupationItem {
  OccupationItem({
    required this.id,
    this.memberId,
    required this.name,
    this.logoUrl,
    this.count,
    this.iconKey,
    this.memberName,
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
      count: json['count'] as int?,
      iconKey: json['iconKey'] as String?,
      memberName: json['memberName'] as String?,
      occupationType: json['occupationTypeName'] as String?,
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
  final String? occupationType;
  final String? companyName;
  final String? businessAddress;
  final String? mobile;
  final String? description;
  final bool isActive;
}
