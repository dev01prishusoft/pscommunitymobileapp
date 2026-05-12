import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

class MockMemberRepository implements MemberRepository {
  bool shouldThrow = false;
  int lastPageNumber = 1;
  String? lastQuery;

  @override
  Future<List<Member>> getMembers() async => [];

  @override
  Future<List<Member>> searchMembers({
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    lastPageNumber = pageNumber;
    lastQuery = query;

    if (shouldThrow) throw Exception('API Error');

    if (pageNumber == 1) {
      return List.generate(20, (i) => Member(memberId: i, firstName: 'A', lastName: 'B'));
    } else if (pageNumber == 2) {
      return List.generate(5, (i) => Member(memberId: 20 + i, firstName: 'C', lastName: 'D'));
    }
    return [];
  }
}

void main() {
  late FindMemberController controller;
  late MockMemberRepository repository;

  setUp(() {
    repository = MockMemberRepository();
    controller = FindMemberController(repository);
  });

  test('loadMembers resets pagination and loads page 1', () async {
    await controller.loadMembers();
    
    expect(controller.state.value, AppState.data);
    expect(controller.members.length, 20);
    expect(controller.hasMore.value, true);
    expect(repository.lastPageNumber, 1);
  });

  test('loadMoreMembers increments page and appends data', () async {
    await controller.loadMembers(); // Page 1
    
    expect(controller.members.length, 20);
    expect(repository.lastPageNumber, 1);
    
    await controller.loadMoreMembers(); // Page 2
    
    expect(controller.members.length, 25);
    expect(repository.lastPageNumber, 2);
    expect(controller.hasMore.value, false);
  });

  test('onSearchChanged updates query', () {
    controller.onSearchChanged('test');
    expect(controller.searchQuery.value, 'test');
  });

  test('error state triggers AppState.error', () async {
    repository.shouldThrow = true;
    await controller.loadMembers();
    
    expect(controller.state.value, AppState.error);
    expect(controller.members.isEmpty, true);
  });
}
