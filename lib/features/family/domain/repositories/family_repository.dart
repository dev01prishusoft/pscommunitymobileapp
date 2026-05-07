import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member_address.dart';

abstract class FamilyRepository {
  Future<List<FamilyArea>> getFamilyAreas({
    int? stateId,
    int? districtId,
    int? talukaId,
  });
  Future<List<Family>> getFamiliesByArea(int areaId);
  Future<Member> getMemberDetails(int memberId);
  Future<List<MemberAddress>> getMemberAddresses(int memberId);
  
  Future<List<DropdownItem>> getStates();
  Future<List<DropdownItem>> getDistricts(int stateId);
  Future<List<DropdownItem>> getTalukas(int districtId);
}
