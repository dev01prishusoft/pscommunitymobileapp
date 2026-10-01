class MemberRegistrationModel {
  bool? succeeded;
  String? message;
  Data? data;

  MemberRegistrationModel({this.succeeded, this.message, this.data});

  MemberRegistrationModel.fromJson(Map<String, dynamic> json) {
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['succeeded'] = this.succeeded;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? samajId;
  bool? requireApproval;
  dynamic updatedAt;

  Data({this.samajId, this.requireApproval, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    samajId = json['samajId'];
    requireApproval = json['requireApproval'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['samajId'] = this.samajId;
    data['requireApproval'] = this.requireApproval;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
