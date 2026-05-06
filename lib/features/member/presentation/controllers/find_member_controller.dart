import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class FindMemberController extends GetxController {
  final MemberRepository _repository;

  FindMemberController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<Member> allMembers = <Member>[].obs;
  final RxList<Member> filteredMembers = <Member>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    state.value = AppState.loading;
    try {
      final members = await _repository.getMembers();
      allMembers.assignAll(members);
      filteredMembers.assignAll(members);
      state.value = members.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load members', e, stack);
      state.value = AppState.error;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMembers.assignAll(allMembers);
      state.value = allMembers.isEmpty ? AppState.empty : AppState.data;
    } else {
      final results = allMembers.where((m) {
        final name = m.name.toLowerCase();
        final info = m.info.toLowerCase();
        final location = m.location.toLowerCase();
        final search = query.toLowerCase();
        return name.contains(search) || info.contains(search) || location.contains(search);
      }).toList();
      
      filteredMembers.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredMembers.assignAll(allMembers);
    state.value = allMembers.isEmpty ? AppState.empty : AppState.data;
  }
}
