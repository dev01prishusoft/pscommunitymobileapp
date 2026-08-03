class FamilyArea {
  FamilyArea({
    required this.id,
    required this.title,
    required this.location,
    required this.members,
    required this.families,
  });

  factory FamilyArea.fromJson(Map<String, dynamic> json) {
    return FamilyArea(
      id: int.tryParse((json['id'] ?? json['areaId'] ?? 0).toString()) ?? 0,
      title: (json['title'] ?? json['areaName'] ?? json['villageName'] ?? '')
          .toString(),
      location:
          (json['location'] ?? json['districtName'] ?? json['talukaName'] ?? '')
              .toString(),
      members:
          int.tryParse(
            (json['members'] ??
                    json['totalMembers'] ??
                    json['memberCount'] ??
                    0)
                .toString(),
          ) ??
          0,
      families:
          int.tryParse(
            (json['families'] ??
                    json['totalFamilies'] ??
                    json['familyCount'] ??
                    0)
                .toString(),
          ) ??
          0,
    );
  }
  final int id;
  final String title;
  final String location;
  final int members;
  final int families;
}
