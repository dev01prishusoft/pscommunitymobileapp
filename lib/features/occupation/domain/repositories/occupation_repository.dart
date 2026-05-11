import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

abstract class OccupationRepository {
  Future<List<OccupationItem>> getOccupations({
    int? occupationTypeId,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<OccupationItem> getOccupationDetails(int id);
  Future<List<DropdownItem>> getOccupationDropdown();
}
