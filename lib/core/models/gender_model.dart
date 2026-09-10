class GenderModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  List<GenderData>? data;

  GenderModel({this.statusCode, this.succeeded, this.message, this.data});

  GenderModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GenderData>[];
      json['data'].forEach((v) {
        data!.add(new GenderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['succeeded'] = this.succeeded;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GenderData {
  int? genderId;
  String? name;

  GenderData({this.genderId, this.name});

  GenderData.fromJson(Map<String, dynamic> json) {
    genderId = json['genderId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['genderId'] = this.genderId;
    data['name'] = this.name;
    return data;
  }

  static List<GenderData> listFromJson(dynamic json) {
    if (json is List) {
      return json
          .map((e) => GenderData.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderData &&
          runtimeType == other.runtimeType &&
          genderId == other.genderId;

  @override
  int get hashCode => genderId.hashCode;

  @override
  String toString() => name ?? '';
}
