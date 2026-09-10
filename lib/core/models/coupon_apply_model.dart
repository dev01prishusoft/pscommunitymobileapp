class CouponApplyModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  CouponApplyData? data;

  CouponApplyModel({this.statusCode, this.succeeded, this.message, this.data});

  CouponApplyModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = CouponApplyData.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json.containsKey('eventCouponId') || json.containsKey('finalAmount')) {
      data = CouponApplyData.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['succeeded'] = succeeded;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CouponApplyData {
  int? eventCouponId;
  int? originalAmount;
  int? discountAmount;
  int? finalAmount;
  bool? isNeedToPay;

  CouponApplyData(
      {this.eventCouponId,
      this.originalAmount,
      this.discountAmount,
      this.finalAmount,
      this.isNeedToPay});

  CouponApplyData.fromJson(Map<String, dynamic> json) {
    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    eventCouponId = map['eventCouponId'] as int?;
    originalAmount = (map['originalAmount'] as num?)?.toInt();
    discountAmount = (map['discountAmount'] as num?)?.toInt();
    finalAmount = (map['finalAmount'] as num?)?.toInt();
    isNeedToPay = map['isNeedToPay'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventCouponId'] = this.eventCouponId;
    data['originalAmount'] = this.originalAmount;
    data['discountAmount'] = this.discountAmount;
    data['finalAmount'] = this.finalAmount;
    data['isNeedToPay'] = this.isNeedToPay;
    return data;
  }
}
