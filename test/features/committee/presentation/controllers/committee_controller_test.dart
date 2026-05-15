import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

class MockCommitteeRepository implements CommitteeRepository {
  bool shouldThrow = false;

  @override
  Future<List<CommitteeNode>> getCommittees({String? searchQuery}) async {
    if (shouldThrow) throw Exception('API Error');
    return [
      CommitteeNode(id: 1, name: 'Root')
    ];
  }

  @override
  Future<CommitteeDetail?> getCommitteeDetail(int id) async {
    if (shouldThrow) throw Exception('API Error');
    return null;
  }
}

void main() {
  late CommitteeController controller;
  late MockCommitteeRepository repository;

  setUp(() {
    repository = MockCommitteeRepository();
    controller = CommitteeController(repository);
  });

  test('loadCommittees fetches data successfully', () async {
    await controller.loadCommittees();
    
    expect(controller.state.value, AppState.data);
    expect(controller.committees.length, 1);
    expect(controller.committees.first.name, 'Root');
  });

  test('error gracefully sets AppState.error', () async {
    repository.shouldThrow = true;
    await controller.loadCommittees();
    
    expect(controller.state.value, AppState.error);
    expect(controller.committees.isEmpty, true);
  });

  test('toggleNode toggles isExpanded and refreshes', () async {
    final node = CommitteeNode(id: 1, name: 'Test');
    expect(node.isExpanded, true);
    
    controller.toggleNode(node);
    
    expect(node.isExpanded, false);
  });

  test('onSearchChanged updates query string', () {
    controller.onSearchChanged('search');
    expect(controller.searchQuery.value, 'search');
  });
}
