class AppSettingModel {
  AppSettingModel({
    required this.appSettingId,
    required this.googleApiKey,
    this.updatedAt,
  });

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      appSettingId: json['appSettingId'] as int? ?? 0,
      googleApiKey: (json['googleApiKey'] as String? ?? '').trim(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  final int appSettingId;
  final String googleApiKey;
  final DateTime? updatedAt;
}
