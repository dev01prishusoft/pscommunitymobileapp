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
}

abstract class FamilyRepository {
  Future<List<FamilyArea>> getFamilyAreas();
}
