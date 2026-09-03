class registeredEventsModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  RegisteredEventData? data;

  registeredEventsModel(
      {this.statusCode, this.succeeded, this.message, this.data});

  registeredEventsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null
        ? new RegisteredEventData.fromJson(json['data'])
        : null;
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

class RegisteredEventData {
  int? totalCount;
  List<RegisteredEventItem>? items;

  RegisteredEventData({this.totalCount, this.items});

  RegisteredEventData.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['items'] != null) {
      items = <RegisteredEventItem>[];
      json['items'].forEach((v) {
        items!.add(new RegisteredEventItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RegisteredEventItem {
  int? eventRegistrationId;
  int? eventId;
  String? eventName;
  String? eventCode;
  String? eventStartDateTime;
  String? eventEndDateTime;
  dynamic timePeriod;
  dynamic eventTypeName;
  dynamic venueName;
  int? memberId;
  String? memberName;
  String? memberNo;
  String? mobileNo;
  String? registrationNumber;
  int? numberOfGuests;
  int? registrationStatusId;
  String? registrationStatusName;
  String? registeredAt;
  dynamic cancelledAt;
  dynamic cancellationReason;
  int? paymentId;
  int? eventCouponId;
  String? couponCode;
  String? notes;
  dynamic originalAmount;
  dynamic discountAmount;
  dynamic finalAmount;
  String? createdAt;

  RegisteredEventItem(
      {this.eventRegistrationId,
      this.eventId,
      this.eventName,
      this.eventCode,
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.timePeriod,
    this.eventTypeName,
    this.venueName,
      this.memberId,
      this.memberName,
      this.memberNo,
      this.mobileNo,
      this.registrationNumber,
      this.numberOfGuests,
      this.registrationStatusId,
      this.registrationStatusName,
      this.registeredAt,
      this.cancelledAt,
      this.cancellationReason,
      this.paymentId,
      this.eventCouponId,
      this.couponCode,
      this.notes,
      this.originalAmount,
      this.discountAmount,
      this.finalAmount,
      this.createdAt});

  RegisteredEventItem.fromJson(Map<String, dynamic> json) {
    eventRegistrationId = json['eventRegistrationId'];
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventCode = json['eventCode'];
    eventStartDateTime = json['eventStartDateTime'];
    eventEndDateTime = json['eventEndDateTime'];
    timePeriod = json['timePeriod'];
    eventTypeName = json['eventTypeName'];
    venueName = json['venueName'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    memberNo = json['memberNo'];
    mobileNo = json['mobileNo'];
    registrationNumber = json['registrationNumber'];
    numberOfGuests = json['numberOfGuests'];
    registrationStatusId = json['registrationStatusId'];
    registrationStatusName = json['registrationStatusName'];
    registeredAt = json['registeredAt'];
    cancelledAt = json['cancelledAt'];
    cancellationReason = json['cancellationReason'];
    paymentId = json['paymentId'];
    eventCouponId = json['eventCouponId'];
    couponCode = json['couponCode'];
    notes = json['notes'];
    originalAmount = json['originalAmount'];
    discountAmount = json['discountAmount'];
    finalAmount = json['finalAmount'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventRegistrationId'] = this.eventRegistrationId;
    data['eventId'] = this.eventId;
    data['eventName'] = this.eventName;
    data['eventCode'] = this.eventCode;
    data['eventStartDateTime'] = this.eventStartDateTime;
    data['eventEndDateTime'] = this.eventEndDateTime;
    data['timePeriod'] = this.timePeriod;
    data['eventTypeName'] = this.eventTypeName;
    data['venueName'] = this.venueName;
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['memberNo'] = this.memberNo;
    data['mobileNo'] = this.mobileNo;
    data['registrationNumber'] = this.registrationNumber;
    data['numberOfGuests'] = this.numberOfGuests;
    data['registrationStatusId'] = this.registrationStatusId;
    data['registrationStatusName'] = this.registrationStatusName;
    data['registeredAt'] = this.registeredAt;
    data['cancelledAt'] = this.cancelledAt;
    data['cancellationReason'] = this.cancellationReason;
    data['paymentId'] = this.paymentId;
    data['eventCouponId'] = this.eventCouponId;
    data['couponCode'] = this.couponCode;
    data['notes'] = this.notes;
    data['originalAmount'] = this.originalAmount;
    data['discountAmount'] = this.discountAmount;
    data['finalAmount'] = this.finalAmount;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
