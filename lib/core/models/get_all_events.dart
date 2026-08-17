class GetAllEvents {
  int? statusCode;
  bool? succeeded;
  String? message;
  Data? data;

  GetAllEvents({this.statusCode, this.succeeded, this.message, this.data});

  GetAllEvents.fromJson(Map<String, dynamic> json) {
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
  int? totalCount;
  List<EventsData>? data;

  Data({this.totalCount, this.data});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['data'] != null) {
      data = <EventsData>[];
      json['data'].forEach((v) {
        data!.add(EventsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventsData {
  int? eventId;
  String? eventType;
  String? eventName;
  String? translatedEventName;
  String? startDateTime;
  String? endDateTime;
  String? venue;
  int? maximumCapacity;
  int? totalRegistrations;
  String? eventMode;
  num? registrationFee;
  bool? isRegistrationRequired;
  bool? isMemberRegistered;
  String? coverImage;

  EventsData(
      {this.eventId,
      this.eventType,
      this.eventName,
      this.translatedEventName,
      this.startDateTime,
      this.endDateTime,
      this.venue,
      this.maximumCapacity,
      this.totalRegistrations,
      this.eventMode,
      this.registrationFee,
      this.isRegistrationRequired,
      this.isMemberRegistered,
      this.coverImage});

  EventsData.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventType = json['eventType'];
    eventName = json['eventName'];
    translatedEventName = json['translatedEventName'];
    startDateTime = json['startDateTime'];
    endDateTime = json['endDateTime'];
    venue = json['venue'];
    maximumCapacity = json['maximumCapacity'];
    totalRegistrations = json['totalRegistrations'];
    eventMode = json['eventMode'];
    registrationFee = json['registrationFee'];
    isRegistrationRequired = json['isRegistrationRequired'];
    isMemberRegistered = json['isMemberRegistered'];
    coverImage = json['coverImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventType'] = this.eventType;
    data['eventName'] = this.eventName;
    data['translatedEventName'] = this.translatedEventName;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    data['venue'] = this.venue;
    data['maximumCapacity'] = this.maximumCapacity;
    data['totalRegistrations'] = this.totalRegistrations;
    data['eventMode'] = this.eventMode;
    data['registrationFee'] = this.registrationFee;
    data['isRegistrationRequired'] = this.isRegistrationRequired;
    data['isMemberRegistered'] = this.isMemberRegistered;
    data['coverImage'] = this.coverImage;
    return data;
  }
}
