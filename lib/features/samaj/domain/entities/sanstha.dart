class Sanstha {
  final String name;
  final String subtitle;
  final String status;
  final String? logoUrl;

  const Sanstha({
    required this.name,
    required this.subtitle,
    required this.status,
    this.logoUrl,
  });

  factory Sanstha.fromJson(Map<String, dynamic> json) {
    return Sanstha(
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      status: json['status'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
