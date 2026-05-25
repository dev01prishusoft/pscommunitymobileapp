class AddressModel {
  AddressModel({
    this.type = '',
    this.state = '',
    this.district = '',
    this.taluka = '',
    this.area = '',
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
      'pincode': pincode,
      'line1': line1,
      'line2': line2,
      'landmark': landmark,
      'isPrimary': isPrimary,
    };
  }
}
