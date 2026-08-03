class MemberAddress {
  MemberAddress({
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

  MemberAddress copyWith({
    int? memberAddressId,
    int? memberId,
    int? addressTypeId,
    String? addressTypeName,
    String? stateName,
    String? districtName,
    String? talukaName,
    String? areaName,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? pincode,
    bool? isPrimary,
  }) {
    return MemberAddress(
      memberAddressId: memberAddressId ?? this.memberAddressId,
      memberId: memberId ?? this.memberId,
      addressTypeId: addressTypeId ?? this.addressTypeId,
      addressTypeName: addressTypeName ?? this.addressTypeName,
      stateName: stateName ?? this.stateName,
      districtName: districtName ?? this.districtName,
      talukaName: talukaName ?? this.talukaName,
      areaName: areaName ?? this.areaName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
