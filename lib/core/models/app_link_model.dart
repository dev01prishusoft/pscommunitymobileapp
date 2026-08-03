class AppLinkModel {
  AppLinkModel({
    required this.applicationLinkId,
    required this.appType,
    required this.appLink,
    required this.currentVersion,
    required this.appUpdateRequired,
  });
 
  factory AppLinkModel.fromJson(Map<String, dynamic> json) {
    return AppLinkModel(
      applicationLinkId: json['applicationLinkId'] as int? ?? 0,
      appType: json['appType'] as String? ?? '',
      appLink: json['appLink'] as String? ?? '',
      currentVersion: json['currentVersion'] as String? ?? '',
      appUpdateRequired: json['appUpdateRequired'] as bool? ?? false,
    );
  }
 
  final int applicationLinkId;
  final String appType;
  final String appLink;
  final String currentVersion;
  final bool appUpdateRequired;
 
  Map<String, dynamic> toJson() {
    return {
      'applicationLinkId': applicationLinkId,
      'appType': appType,
      'appLink': appLink,
      'currentVersion': currentVersion,
      'appUpdateRequired': appUpdateRequired,
    };
  }
}
