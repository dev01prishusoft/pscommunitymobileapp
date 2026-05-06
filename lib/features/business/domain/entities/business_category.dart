class BusinessCategory {
  final String title;
  final String iconKey;

  const BusinessCategory({
    required this.title,
    required this.iconKey,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      title: json['title'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
    );
  }
}
