import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/models/occupation_item.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';

abstract class OccupationRepository {
  Future<List<OccupationItem>> getOccupations({
    int? occupationTypeId,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<OccupationItem> getOccupationDetails(int id);
  Future<List<DropdownItem>> getOccupationDropdown();
  Future<List<Member>> getOccupationMembers({
    required int occupationId,
    String? search,
    int? stateId,
    int? districtId,
    int? talukaId,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
