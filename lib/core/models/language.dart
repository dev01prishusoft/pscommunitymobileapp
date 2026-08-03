class Language {
  Language({required this.id, required this.name, required this.code});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
  final int id;
  final String name;
  final String code;
}
