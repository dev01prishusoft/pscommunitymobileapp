class FamilyArea {
  final String title;
  final String location;
  final int members;
  final int families;

  const FamilyArea({
    required this.title,
    required this.location,
    required this.members,
    required this.families,
  });

  factory FamilyArea.fromJson(Map<String, dynamic> json) {
    return FamilyArea(
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      members: json['members'] as int? ?? 0,
      families: json['families'] as int? ?? 0,
    );
  }
}
