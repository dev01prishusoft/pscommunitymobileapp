class EventCreateOrderModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  CreateOrderData? data;

  EventCreateOrderModel(
      {this.statusCode, this.succeeded, this.message, this.data});

  EventCreateOrderModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null ? new CreateOrderData.fromJson(json['data']) : null;
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

class CreateOrderData {
  String? orderId;
  dynamic amountInPaise;
  dynamic finalAmount;
  dynamic originalAmount;
  dynamic discountAmount;
  String? currency;
  String? keyId;

  CreateOrderData(
      {this.orderId,
      this.amountInPaise,
      this.finalAmount,
      this.originalAmount,
      this.discountAmount,
      this.currency,
      this.keyId});

  CreateOrderData.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    amountInPaise = json['amountInPaise'];
    finalAmount = json['finalAmount'];
    originalAmount = json['originalAmount'];
    discountAmount = json['discountAmount'];
    currency = json['currency'];
    keyId = json['keyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['amountInPaise'] = this.amountInPaise;
    data['finalAmount'] = this.finalAmount;
    data['originalAmount'] = this.originalAmount;
    data['discountAmount'] = this.discountAmount;
    data['currency'] = this.currency;
    data['keyId'] = this.keyId;
    return data;
  }
}
