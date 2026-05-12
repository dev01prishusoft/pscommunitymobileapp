import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

class MockFamilyRepository implements FamilyRepository {
  bool shouldThrow = false;
  int getAreasCallCount = 0;
  int lastPageNo = 1;

  @override
  Future<List<FamilyArea>> getFamilyAreas({
    int? stateId,
    int? districtId,
    int? talukaId,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    getAreasCallCount++;
    lastPageNo = pageNo;
    
    if (shouldThrow) throw Exception('API Error');

    if (pageNo == 1) {
      return List.generate(20, (i) => FamilyArea(id: i, title: 'Title', location: 'Loc', members: 10, families: 2));
    } else if (pageNo == 2) {
      return List.generate(5, (i) => FamilyArea(id: 20 + i, title: 'Title', location: 'Loc', members: 10, families: 2));
    }
    return [];
  }

  @override
  Future<List<DropdownItem>> getStates() async => [DropdownItem(id: 1, text: 'Gujarat')];
  
  @override
  Future<List<DropdownItem>> getDistricts(int stateId) async => [DropdownItem(id: 2, text: 'Ahmedabad')];
  
  @override
  Future<List<DropdownItem>> getTalukas(int districtId) async => [DropdownItem(id: 3, text: 'Daskroi')];
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FamilyController controller;
  late MockFamilyRepository repository;

  setUp(() {
    repository = MockFamilyRepository();
    controller = FamilyController(repository);
  });

  test('pagination and loadMore increments page correctly', () async {
    await controller.loadAreas(refresh: true);
    expect(controller.areas.length, 20);
    expect(controller.hasMore.value, true);
    expect(repository.lastPageNo, 1);

    await controller.loadAreas(refresh: false);
    expect(controller.areas.length, 25);
    expect(controller.hasMore.value, false);
    expect(repository.lastPageNo, 2);
  });

  test('filter cascade triggers data reload correctly', () async {
    await controller.onStateChanged(DropdownItem(id: 1, text: 'Gujarat'));
    expect(controller.selectedState.value?.text, 'Gujarat');
    expect(repository.getAreasCallCount, 1); // it reloads areas when state changes
    expect(controller.districts.length, 1); // loaded districts
    expect(controller.talukas.isEmpty, true);

    await controller.onDistrictChanged(DropdownItem(id: 2, text: 'Ahmedabad'));
    expect(controller.selectedDistrict.value?.text, 'Ahmedabad');
    expect(repository.getAreasCallCount, 2);
    expect(controller.talukas.length, 1);
  });

  test('error gracefully sets AppState.error', () async {
    repository.shouldThrow = true;
    await controller.loadAreas(refresh: true);
    expect(controller.state.value, AppState.error);
    expect(controller.areas.isEmpty, true);
  });
}
