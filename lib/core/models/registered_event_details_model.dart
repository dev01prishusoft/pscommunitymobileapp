class registeredEventsDetailsModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  Data? data;

  registeredEventsDetailsModel(
      {this.statusCode, this.succeeded, this.message, this.data});

  registeredEventsDetailsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  int? eventRegistrationId;
  int? eventId;
  String? eventName;
  String? eventCode;
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
  double? finalAmount;
  double? discountAmount;
  int? originalAmount;
  String? createdAt;
  String? qrCodeData;
  List<Guests>? guests;

  Data(
      {this.eventRegistrationId,
      this.eventId,
      this.eventName,
      this.eventCode,
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
      this.finalAmount,
      this.discountAmount,
      this.originalAmount,
      this.createdAt,
      this.qrCodeData,
      this.guests});

  Data.fromJson(Map<String, dynamic> json) {
    eventRegistrationId = json['eventRegistrationId'];
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventCode = json['eventCode'];
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
    finalAmount = json['finalAmount'];
    discountAmount = json['discountAmount'];
    originalAmount = json['originalAmount'];
    createdAt = json['createdAt'];
    qrCodeData = json['qrCodeData'];
    if (json['guests'] != null) {
      guests = <Guests>[];
      json['guests'].forEach((v) {
        guests!.add(new Guests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventRegistrationId'] = this.eventRegistrationId;
    data['eventId'] = this.eventId;
    data['eventName'] = this.eventName;
    data['eventCode'] = this.eventCode;
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
    data['finalAmount'] = this.finalAmount;
    data['discountAmount'] = this.discountAmount;
    data['originalAmount'] = this.originalAmount;
    data['createdAt'] = this.createdAt;
    data['qrCodeData'] = this.qrCodeData;
    if (this.guests != null) {
      data['guests'] = this.guests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Guests {
  int? eventRegistrationGuestId;
  int? eventRegistrationId;
  dynamic memberId;
  String? memberName;
  String? guestName;
  String? mobileNo;
  int? age;
  int? genderId;
  String? genderName;
  bool? isAttended;
  dynamic checkedInAt;
  String? createdAt;

  Guests(
      {this.eventRegistrationGuestId,
      this.eventRegistrationId,
      this.memberId,
      this.memberName,
      this.guestName,
      this.mobileNo,
      this.age,
      this.genderId,
      this.genderName,
      this.isAttended,
      this.checkedInAt,
      this.createdAt});

  Guests.fromJson(Map<String, dynamic> json) {
    eventRegistrationGuestId = json['eventRegistrationGuestId'];
    eventRegistrationId = json['eventRegistrationId'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    guestName = json['guestName'];
    mobileNo = json['mobileNo'];
    age = json['age'];
    genderId = json['genderId'];
    genderName = json['genderName'];
    isAttended = json['isAttended'];
    checkedInAt = json['checkedInAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventRegistrationGuestId'] = this.eventRegistrationGuestId;
    data['eventRegistrationId'] = this.eventRegistrationId;
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['guestName'] = this.guestName;
    data['mobileNo'] = this.mobileNo;
    data['age'] = this.age;
    data['genderId'] = this.genderId;
    data['genderName'] = this.genderName;
    data['isAttended'] = this.isAttended;
    data['checkedInAt'] = this.checkedInAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
