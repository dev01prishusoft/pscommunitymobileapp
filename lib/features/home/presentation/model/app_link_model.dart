class AppLinkModel {
  AppLinkModel({
    required this.applicationLinkId,
    required this.appType,
    required this.appLink,
  });
 
  factory AppLinkModel.fromJson(Map<String, dynamic> json) {
    return AppLinkModel(
      applicationLinkId: json['applicationLinkId'] as int? ?? 0,
      appType: json['appType'] as String? ?? '',
      appLink: json['appLink'] as String? ?? '',
    );
  }
 
  final int applicationLinkId;
  final String appType;
  final String appLink;
 
  Map<String, dynamic> toJson() {
    return {
      'applicationLinkId': applicationLinkId,
      'appType': appType,
      'appLink': appLink,
    };
  }
}
