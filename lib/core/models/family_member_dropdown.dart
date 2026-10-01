class FamilyMemberDropDown {
  int? statusCode;
  bool? succeeded;
  String? message;
  List<Data>? data;

  FamilyMemberDropDown(
      {this.statusCode, this.succeeded, this.message, this.data});

  FamilyMemberDropDown.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  int? memberId;
  String? fullName;
  int? headMemberId;

  Data({this.memberId, this.fullName, this.headMemberId});

  Data.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    fullName = json['fullName'];
    headMemberId = json['headMemberId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberId'] = this.memberId;
    data['fullName'] = this.fullName;
    data['headMemberId'] = this.headMemberId;
    return data;
  }
}
