class SamajSanstha {
  SamajSanstha({
    required this.samajSansthaId,
    required this.samajId,
    required this.name,
    required this.description,
    required this.nameEnglish,
    required this.descriptionEnglish,
    required this.isActive,
  });

  factory SamajSanstha.fromJson(Map<String, dynamic> json) {
    return SamajSanstha(
      samajSansthaId: json['samajSansthaId'] as int? ?? 0,
      samajId: json['samajId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      nameEnglish: json['nameEnglish'] as String? ?? '',
      descriptionEnglish: json['descriptionEnglish'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  final int samajSansthaId;
  final int samajId;
  final String name;
  final String description;
  final String nameEnglish;
  final String descriptionEnglish;
  final bool isActive;
}
