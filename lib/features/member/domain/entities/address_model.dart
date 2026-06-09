class AddressModel {
  AddressModel({
    this.type = '',
    this.state = '',
    this.district = '',
    this.taluka = '',
    this.area = '',
    this.stateId,
    this.districtId,
    this.talukaId,
    this.areaId,
    this.pincode = '',
    this.line1 = '',
    this.line2 = '',
    this.landmark = '',
    this.isPrimary = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      type: json['type'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      taluka: json['taluka'] as String? ?? '',
      area: json['area'] as String? ?? '',
      stateId: json['stateId'] as int?,
      districtId: json['districtId'] as int?,
      talukaId: json['talukaId'] as int?,
      areaId: json['areaId'] as int?,
      pincode: json['pincode'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
  String type;
  String state;
  String district;
  String taluka;
  String area;
  int? stateId;
  int? districtId;
  int? talukaId;
  int? areaId;
  String pincode;
  String line1;
  String line2;
  String landmark;
  bool isPrimary;

  AddressModel copyWith({
    String? type,
    String? state,
    String? district,
    String? taluka,
    String? area,
    int? stateId,
    int? districtId,
    int? talukaId,
    int? areaId,
    String? pincode,
    String? line1,
    String? line2,
    String? landmark,
    bool? isPrimary,
  }) {
    return AddressModel(
      type: type ?? this.type,
      state: state ?? this.state,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      area: area ?? this.area,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      talukaId: talukaId ?? this.talukaId,
      areaId: areaId ?? this.areaId,
      pincode: pincode ?? this.pincode,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      landmark: landmark ?? this.landmark,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'state': state,
      'district': district,
      'taluka': taluka,
      'area': area,
      'stateId': stateId,
      'districtId': districtId,
      'talukaId': talukaId,
      'areaId': areaId,
      'pincode': pincode,
      'line1': line1,
      'line2': line2,
      'landmark': landmark,
      'isPrimary': isPrimary,
    };
  }
}
