import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

abstract class OccupationRepository {
  Future<List<OccupationItem>> getOccupations({int? occupationTypeId});
  Future<OccupationItem> getOccupationDetails(int id);
}
