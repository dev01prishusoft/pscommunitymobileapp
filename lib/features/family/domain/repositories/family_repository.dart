import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';

abstract class FamilyRepository {
  Future<List<FamilyArea>> getFamilyAreas();
  Future<List<Family>> getFamilies(String areaName);
}
