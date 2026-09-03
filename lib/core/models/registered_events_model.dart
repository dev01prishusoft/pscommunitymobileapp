import 'package:pscommunitymobileapp/core/models/registered_event_details_model.dart';

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
  String? venueAddress;
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
  int? eventCouponId;
  String? couponCode;
  String? notes;
  dynamic originalAmount;
  dynamic discountAmount;
  dynamic finalAmount;
  String? createdAt;
  List<Guests>? guests;

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
    this.venueAddress,
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
      this.originalAmount,
      this.discountAmount,
      this.finalAmount,
      this.createdAt,
      this.guests});

  RegisteredEventItem.fromJson(Map<String, dynamic> json) {
    eventRegistrationId = _toInt(json['eventRegistrationId'] ?? json['EventRegistrationId'] ?? json['registrationId'] ?? json['id']);
    eventId = _toInt(json['eventId'] ?? json['EventId']);
    eventName = (json['eventName'] ?? json['EventName'])?.toString();
    eventCode = (json['eventCode'] ?? json['EventCode'])?.toString();
    eventStartDateTime = (json['eventStartDateTime'] ?? json['EventStartDateTime'])?.toString();
    eventEndDateTime = (json['eventEndDateTime'] ?? json['EventEndDateTime'])?.toString();
    timePeriod = json['timePeriod'] ?? json['TimePeriod'];
    eventTypeName = (json['eventTypeName'] ?? json['EventTypeName'])?.toString();
    venueName = (json['venueName'] ?? json['VenueName'])?.toString();
    venueAddress = (json['venueAddress'] ?? json['VenueAddress'])?.toString();
    venueGoogleMapUrl = json['venueGoogleMapUrl'] ?? json['VenueGoogleMapUrl'];
    memberId = _toInt(json['memberId'] ?? json['MemberId']);
    memberName = (json['memberName'] ?? json['MemberName'])?.toString();
    memberNo = (json['memberNo'] ?? json['MemberNo'])?.toString();
    mobileNo = (json['mobileNo'] ?? json['MobileNo'])?.toString();
    registrationNumber = (json['registrationNumber'] ?? json['RegistrationNumber'] ?? json['eventCode'])?.toString();
    numberOfGuests = _toInt(json['numberOfGuests'] ?? json['NumberOfGuests'] ?? json['guestCount'] ?? json['GuestCount']);
    registrationStatusId = _toInt(json['registrationStatusId'] ?? json['RegistrationStatusId']);
    registrationStatusName = (json['registrationStatusName'] ?? json['RegistrationStatusName'])?.toString();
    registeredAt = (json['registeredAt'] ?? json['RegisteredAt'])?.toString();
    cancelledAt = json['cancelledAt'] ?? json['CancelledAt'];
    cancellationReason = json['cancellationReason'] ?? json['CancellationReason'];
    paymentId = _toInt(json['paymentId'] ?? json['PaymentId']);
    eventCouponId = _toInt(json['eventCouponId'] ?? json['EventCouponId']);
    couponCode = (json['couponCode'] ?? json['CouponCode'])?.toString();
    notes = (json['notes'] ?? json['Notes'])?.toString();
    originalAmount = json['originalAmount'] ?? json['OriginalAmount'];
    discountAmount = json['discountAmount'] ?? json['DiscountAmount'];
    finalAmount = json['finalAmount'] ?? json['FinalAmount'];
    createdAt = (json['createdAt'] ?? json['CreatedAt'])?.toString();

    final rawGuests = json['guests'] ??
        json['Guests'] ??
        json['eventRegistrationGuests'] ??
        json['EventRegistrationGuests'] ??
        json['eventGuests'] ??
        json['EventGuests'] ??
        json['guestList'] ??
        json['GuestList'] ??
        json['registrationGuests'] ??
        json['RegistrationGuests'];

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

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
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
