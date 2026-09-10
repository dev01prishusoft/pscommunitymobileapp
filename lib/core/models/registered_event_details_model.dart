class RegisteredEventsDetailsModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  RegisteredEventsDetailsData? data;

  RegisteredEventsDetailsModel(
      {this.statusCode, this.succeeded, this.message, this.data});

  RegisteredEventsDetailsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null
        ? new RegisteredEventsDetailsData.fromJson(json['data'])
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

class RegisteredEventsDetailsData {
  int? eventRegistrationId;
  int? eventId;
  String? eventName;
  String? eventCode;
  String? eventStartDateTime;
  String? eventEndDateTime;
  String? timePeriod;
  String? eventTypeName;
  String? venueName;
  String? venueAddress;
  double? venueLatitude;
  double? venueLongitude;
  dynamic venueGoogleMapUrl;
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
  dynamic eventCouponId;
  dynamic couponCode;
  String? notes;
  num? finalAmount;
  num? discountAmount;
  num? originalAmount;
  String? createdAt;
  String? qrCodeData;
  List<Guests>? guests;

  RegisteredEventsDetailsData(
      {this.eventRegistrationId,
      this.eventId,
      this.eventName,
      this.eventCode,
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.timePeriod,
    this.eventTypeName,
    this.venueName,
    this.venueAddress,
    this.venueLatitude,
    this.venueLongitude,
    this.venueGoogleMapUrl,
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

  RegisteredEventsDetailsData.fromJson(Map<String, dynamic> json) {
    eventRegistrationId = json['eventRegistrationId'];
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventCode = json['eventCode'];
    eventStartDateTime = json['eventStartDateTime'];
    eventEndDateTime = json['eventEndDateTime'];
    timePeriod = json['timePeriod'];
    eventTypeName = json['eventTypeName'];
    venueName = json['venueName'];
    venueAddress = json['venueAddress'];
    venueLatitude = (json['venueLatitude'] as num?)?.toDouble() ??
        double.tryParse(json['venueLatitude']?.toString() ?? '');
    venueLongitude = (json['venueLongitude'] as num?)?.toDouble() ??
        double.tryParse(json['venueLongitude']?.toString() ?? '');
    venueGoogleMapUrl = json['venueGoogleMapUrl'];
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
    finalAmount = json['finalAmount'] is num
        ? json['finalAmount']
        : num.tryParse(json['finalAmount']?.toString() ?? '');
    discountAmount = json['discountAmount'] is num
        ? json['discountAmount']
        : num.tryParse(json['discountAmount']?.toString() ?? '');
    originalAmount = json['originalAmount'] is num
        ? json['originalAmount']
        : num.tryParse(json['originalAmount']?.toString() ?? '');
    createdAt = json['createdAt'];
    qrCodeData = json['qrCodeData'];
    final rawGuests = json['guests'] ?? json['Guests'];
    if (rawGuests != null && rawGuests is List) {
      guests = <Guests>[];
      for (final v in rawGuests) {
        if (v is Map<String, dynamic>) {
          guests!.add(Guests.fromJson(v));
        } else if (v is Map) {
          guests!.add(Guests.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
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
    data['venueAddress'] = this.venueAddress;
    data['venueLatitude'] = this.venueLatitude;
    data['venueLongitude'] = this.venueLongitude;
    data['venueGoogleMapUrl'] = this.venueGoogleMapUrl;
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
    eventRegistrationGuestId = json['eventRegistrationGuestId'] is num
        ? (json['eventRegistrationGuestId'] as num).toInt()
        : int.tryParse(json['eventRegistrationGuestId']?.toString() ?? '');
    eventRegistrationId = json['eventRegistrationId'] is num
        ? (json['eventRegistrationId'] as num).toInt()
        : int.tryParse(json['eventRegistrationId']?.toString() ?? '');
    memberId = json['memberId'];
    memberName = json['memberName']?.toString();
    guestName = (json['guestName'] ?? json['memberName'])?.toString();
    mobileNo = json['mobileNo']?.toString();
    age = json['age'] is num
        ? (json['age'] as num).toInt()
        : int.tryParse(json['age']?.toString() ?? '');
    genderId = json['genderId'] is num
        ? (json['genderId'] as num).toInt()
        : int.tryParse(json['genderId']?.toString() ?? '');
    genderName = json['genderName']?.toString();
    isAttended = json['isAttended'];
    checkedInAt = json['checkedInAt'];
    createdAt = json['createdAt']?.toString();
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
