class OccupationItem {
  final String name;
  final int count;
  final String iconKey;

  const OccupationItem({
    required this.name,
    required this.count,
    required this.iconKey,
  });

  factory OccupationItem.fromJson(Map<String, dynamic> json) {
    return OccupationItem(
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      iconKey: json['iconKey'] as String? ?? '',
    );
  }
}
