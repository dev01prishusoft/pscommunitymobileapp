class EventValidateModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  EventValidateData? data;

  EventValidateModel(
      {this.statusCode, this.succeeded, this.message, this.data});

  EventValidateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null ? new EventValidateData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['succeeded'] = this.succeeded;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class EventValidateData {
  int? originalAmount;
  bool? isNeedToPay;

  EventValidateData({this.originalAmount, this.isNeedToPay});

  EventValidateData.fromJson(Map<String, dynamic> json) {
    originalAmount = json['originalAmount'] is int
        ? json['originalAmount'] as int
        : (json['originalAmount'] is num
            ? (json['originalAmount'] as num).toInt()
            : null);
    isNeedToPay = json['isNeedToPay'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['originalAmount'] = this.originalAmount;
    data['isNeedToPay'] = this.isNeedToPay;
    return data;
  }
}
