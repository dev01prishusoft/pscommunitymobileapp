class MemberAddress {
  final int memberAddressId;
  final int memberId;
  final int addressTypeId;
  final String addressTypeName;
  final String stateName;
  final String districtName;
  final String talukaName;
  final String areaName;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String pincode;
  final bool isPrimary;

  const MemberAddress({
    required this.memberAddressId,
    required this.memberId,
    required this.addressTypeId,
    required this.addressTypeName,
    required this.stateName,
    required this.districtName,
    required this.talukaName,
    required this.areaName,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.pincode,
    required this.isPrimary,
  });

  factory MemberAddress.fromJson(Map<String, dynamic> json) {
    return MemberAddress(
      memberAddressId: json['memberAddressId'] as int? ?? 0,
      memberId: json['memberId'] as int? ?? 0,
      addressTypeId: json['addressTypeId'] as int? ?? 0,
      addressTypeName: json['addressTypeName'] as String? ?? '',
      stateName: json['stateName'] as String? ?? '',
      districtName: json['districtName'] as String? ?? '',
      talukaName: json['talukaName'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      landmark,
      areaName,
      talukaName,
      districtName,
      stateName,
      pincode,
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(', ');
  }
}
