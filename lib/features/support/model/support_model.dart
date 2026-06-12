class SamajSupportTeam {

  SamajSupportTeam({

    this.whatsAppNumber,

    this.contactEmail,

    this.members = const [],

  });
 
  factory SamajSupportTeam.fromJson(Map<String, dynamic> json) {

    return SamajSupportTeam(

      whatsAppNumber: json['whatsAppNumber'] as String?,

      contactEmail: json['contactEmail'] as String?,

      members: (json['members'] as List<dynamic>?)

              ?.map((e) => SupportTeamMember.fromJson(e as Map<String, dynamic>))

              .toList() ??

          [],

    );

  }
 
  final String? whatsAppNumber;

  final String? contactEmail;

  final List<SupportTeamMember> members;
 
  Map<String, dynamic> toJson() {

    return {

      'whatsAppNumber': whatsAppNumber,

      'contactEmail': contactEmail,

      'members': members.map((e) => e.toJson()).toList(),

    };

  }

}
 
class SupportTeamMember {

  SupportTeamMember({

    required this.memberId,

    required this.displayName,

  });
 
  factory SupportTeamMember.fromJson(Map<String, dynamic> json) {

    return SupportTeamMember(

      memberId: json['memberId'] as int? ?? 0,

      displayName: json['displayName'] as String? ?? '',

    );

  }
 
  final int memberId;

  final String displayName;
 
  Map<String, dynamic> toJson() {

    return {

      'memberId': memberId,

      'displayName': displayName,

    };

  }

}

 