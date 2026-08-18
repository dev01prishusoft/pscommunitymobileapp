class EventDetailsResponse {
  int? statusCode;
  bool? succeeded;
  String? message;
  EventDetailsData? data;

  EventDetailsResponse({this.statusCode, this.succeeded, this.message, this.data});

  EventDetailsResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    succeeded = json['succeeded'];
    message = json['message'];
    data = json['data'] != null ? new EventDetailsData.fromJson(json['data']) : null;
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

class EventDetailsData {
  int? eventId;
  String? eventType;
  String? eventMode;
  String? eventName;
  String? translatedEventName;
  String? startDateTime;
  String? endDateTime;
  String? shortDescription;
  String? translatedShortDescription;
  String? description;
  String? translatedDescription;
  String? termsAndConditions;
  String? translatedTermsAndConditions;
  num? maximumGuestsPerMember;
  num? registrationFee;
  bool? isRegistrationRequired;
  num? totalRegistrations;
  bool? isMemberRegistered;
  String? venueName;
  String? googleMapUrl;
  String? addressLine1;
  String? addressLine2;
  String? landmark;
  String? pincode;
  dynamic committeeName;
  String? organizerName;
  dynamic organizerMobileNo;
  List<Schedules>? schedules;
  List<Medias>? medias;
  List<Organizers>? organizers;

  EventDetailsData(
      {this.eventId,
      this.eventType,
      this.eventMode,
      this.eventName,
      this.translatedEventName,
      this.startDateTime,
      this.endDateTime,
      this.shortDescription,
      this.translatedShortDescription,
      this.description,
      this.translatedDescription,
      this.termsAndConditions,
      this.translatedTermsAndConditions,
      this.maximumGuestsPerMember,
      this.registrationFee,
      this.isRegistrationRequired,
      this.totalRegistrations,
      this.isMemberRegistered,
      this.venueName,
      this.googleMapUrl,
      this.addressLine1,
      this.addressLine2,
      this.landmark,
      this.pincode,
      this.committeeName,
      this.organizerName,
      this.organizerMobileNo,
      this.schedules,
      this.medias,
      this.organizers});

  EventDetailsData.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventType = json['eventType'];
    eventMode = json['eventMode'];
    eventName = json['eventName'];
    translatedEventName = json['translatedEventName'];
    startDateTime = json['startDateTime'];
    endDateTime = json['endDateTime'];
    shortDescription = json['shortDescription'];
    translatedShortDescription = json['translatedShortDescription'];
    description = json['description'];
    translatedDescription = json['translatedDescription'];
    termsAndConditions = json['termsAndConditions'];
    translatedTermsAndConditions = json['translatedTermsAndConditions'];
    maximumGuestsPerMember = json['maximumGuestsPerMember'];
    registrationFee = json['registrationFee'];
    isRegistrationRequired = json['isRegistrationRequired'];
    totalRegistrations = json['totalRegistrations'];
    isMemberRegistered = json['isMemberRegistered'];
    venueName = json['venueName'];
    googleMapUrl = json['googleMapUrl'];
    addressLine1 = json['addressLine1'];
    addressLine2 = json['addressLine2'];
    landmark = json['landmark'];
    pincode = json['pincode'];
    committeeName = json['committeeName'];
    organizerName = json['organizerName'];
    organizerMobileNo = json['organizerMobileNo'];
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(new Schedules.fromJson(v));
      });
    }
    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(new Medias.fromJson(v));
      });
    }
    if (json['organizers'] != null) {
      organizers = <Organizers>[];
      json['organizers'].forEach((v) {
        organizers!.add(new Organizers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventType'] = this.eventType;
    data['eventMode'] = this.eventMode;
    data['eventName'] = this.eventName;
    data['translatedEventName'] = this.translatedEventName;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    data['shortDescription'] = this.shortDescription;
    data['translatedShortDescription'] = this.translatedShortDescription;
    data['description'] = this.description;
    data['translatedDescription'] = this.translatedDescription;
    data['termsAndConditions'] = this.termsAndConditions;
    data['translatedTermsAndConditions'] = this.translatedTermsAndConditions;
    data['maximumGuestsPerMember'] = this.maximumGuestsPerMember;
    data['registrationFee'] = this.registrationFee;
    data['isRegistrationRequired'] = this.isRegistrationRequired;
    data['totalRegistrations'] = this.totalRegistrations;
    data['isMemberRegistered'] = this.isMemberRegistered;
    data['venueName'] = this.venueName;
    data['googleMapUrl'] = this.googleMapUrl;
    data['addressLine1'] = this.addressLine1;
    data['addressLine2'] = this.addressLine2;
    data['landmark'] = this.landmark;
    data['pincode'] = this.pincode;
    data['committeeName'] = this.committeeName;
    data['organizerName'] = this.organizerName;
    data['organizerMobileNo'] = this.organizerMobileNo;
    if (this.schedules != null) {
      data['schedules'] = this.schedules!.map((v) => v.toJson()).toList();
    }
    if (this.medias != null) {
      data['medias'] = this.medias!.map((v) => v.toJson()).toList();
    }
    if (this.organizers != null) {
      data['organizers'] = this.organizers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Schedules {
  String? sessionName;
  String? speakerName;
  String? scheduleStartDateTime;
  String? scheduleEndDateTime;
  String? sessionDescription;
  int? eventVenueId;
  String? scheduleVenueName;
  String? scheduleGoogleMapUrl;
  String? scheduleAddressLine1;
  String? scheduleAddressLine2;
  String? schedulePincode;
  String? scheduleLandmark;

  Schedules(
      {this.sessionName,
      this.speakerName,
      this.scheduleStartDateTime,
      this.scheduleEndDateTime,
      this.sessionDescription,
      this.eventVenueId,
      this.scheduleVenueName,
      this.scheduleGoogleMapUrl,
      this.scheduleAddressLine1,
      this.scheduleAddressLine2,
      this.schedulePincode,
      this.scheduleLandmark});

  Schedules.fromJson(Map<String, dynamic> json) {
    sessionName = json['sessionName'];
    speakerName = json['speakerName'];
    scheduleStartDateTime = json['scheduleStartDateTime'];
    scheduleEndDateTime = json['scheduleEndDateTime'];
    sessionDescription = json['sessionDescription'];
    eventVenueId = json['eventVenueId'];
    scheduleVenueName = json['scheduleVenueName'];
    scheduleGoogleMapUrl = json['scheduleGoogleMapUrl'];
    scheduleAddressLine1 = json['scheduleAddressLine1'];
    scheduleAddressLine2 = json['scheduleAddressLine2'];
    schedulePincode = json['schedulePincode'];
    scheduleLandmark = json['scheduleLandmark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionName'] = this.sessionName;
    data['speakerName'] = this.speakerName;
    data['scheduleStartDateTime'] = this.scheduleStartDateTime;
    data['scheduleEndDateTime'] = this.scheduleEndDateTime;
    data['sessionDescription'] = this.sessionDescription;
    data['eventVenueId'] = this.eventVenueId;
    data['scheduleVenueName'] = this.scheduleVenueName;
    data['scheduleGoogleMapUrl'] = this.scheduleGoogleMapUrl;
    data['scheduleAddressLine1'] = this.scheduleAddressLine1;
    data['scheduleAddressLine2'] = this.scheduleAddressLine2;
    data['schedulePincode'] = this.schedulePincode;
    data['scheduleLandmark'] = this.scheduleLandmark;
    return data;
  }
}

class Medias {
  String? type;
  String? format;
  String? url;
  String? thumbnailUrl;
  String? caption;
  String? alternativeText;
  bool? isCoverImage;
  bool? isGalleryVisible;

  Medias(
      {this.type,
      this.format,
      this.url,
      this.thumbnailUrl,
      this.caption,
      this.alternativeText,
      this.isCoverImage,
      this.isGalleryVisible});

  Medias.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    format = json['format'];
    url = json['url'];
    thumbnailUrl = json['thumbnailUrl'];
    caption = json['caption'];
    alternativeText = json['alternativeText'];
    isCoverImage = json['isCoverImage'];
    isGalleryVisible = json['isGalleryVisible'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['format'] = this.format;
    data['url'] = this.url;
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['caption'] = this.caption;
    data['alternativeText'] = this.alternativeText;
    data['isCoverImage'] = this.isCoverImage;
    data['isGalleryVisible'] = this.isGalleryVisible;
    return data;
  }
}

class Organizers {
  int? eventOrganizerId;
  int? memberId;
  int? committeeId;
  String? committeeName;
  String? memberName;
  String? mobileNo;
  String? email;
  List<CommitteeMembers>? committeeMembers;

  Organizers(
      {this.eventOrganizerId,
      this.memberId,
      this.committeeId,
      this.committeeName,
      this.memberName,
      this.mobileNo,
      this.email,
      this.committeeMembers});

  Organizers.fromJson(Map<String, dynamic> json) {
    eventOrganizerId = json['eventOrganizerId'];
    memberId = json['memberId'];
    committeeId = json['committeeId'];
    committeeName = json['committeeName'];
    memberName = json['memberName'];
    mobileNo = json['mobileNo'];
    email = json['email'];
    if (json['committeeMembers'] != null) {
      committeeMembers = <CommitteeMembers>[];
      json['committeeMembers'].forEach((v) {
        committeeMembers!.add(new CommitteeMembers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventOrganizerId'] = this.eventOrganizerId;
    data['memberId'] = this.memberId;
    data['committeeId'] = this.committeeId;
    data['committeeName'] = this.committeeName;
    data['memberName'] = this.memberName;
    data['mobileNo'] = this.mobileNo;
    data['email'] = this.email;
    if (this.committeeMembers != null) {
      data['committeeMembers'] =
          this.committeeMembers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommitteeMembers {
  int? committeeMemberId;
  int? memberId;
  String? memberName;
  String? mobileNo;
  String? email;

  CommitteeMembers(
      {this.committeeMemberId,
      this.memberId,
      this.memberName,
      this.mobileNo,
      this.email});

  CommitteeMembers.fromJson(Map<String, dynamic> json) {
    committeeMemberId = json['committeeMemberId'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    mobileNo = json['mobileNo'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['committeeMemberId'] = this.committeeMemberId;
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['mobileNo'] = this.mobileNo;
    data['email'] = this.email;
    return data;
  }
}
