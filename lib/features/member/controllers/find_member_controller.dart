import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';
import 'package:pscommunitymobileapp/features/member/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/features/family/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

class FindMemberController extends PaginationMixin<Member> {
  FindMemberController(this._repository, this._familyRepository);
  final MemberRepository _repository;
  final FamilyRepository _familyRepository;

  final RxString searchQuery = ''.obs;

  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isTalukasLoading = false.obs;
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;
  final Rxn<DropdownItem> selectedState = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedDistrict = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedTaluka = Rxn<DropdownItem>();

  @override
  void onInit() {
    super.onInit();
    refreshData(showInitialLoading: true);
    loadStates();
  }

  Future<void> loadStates() async {
    isStatesLoading.value = true;
    try {
      final results = await _familyRepository.getStates();
      states.assignAll(results);
    } catch (_) {
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<List<DropdownItem>> fetchDistricts(int stateId) async {
    return _familyRepository.getDistricts(stateId);
  }

  Future<List<DropdownItem>> fetchTalukas(int districtId) async {
    return _familyRepository.getTalukas(districtId);
  }

  Future<void> applyFilters({
    required DropdownItem? state,
    required DropdownItem? district,
    required DropdownItem? taluka,
  }) async {
    selectedState.value = state;
    selectedDistrict.value = district;
    selectedTaluka.value = taluka;

    refreshData(showInitialLoading: true);
  }

  Future<void> resetFilters() async {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();
    
    refreshData(showInitialLoading: true);
  }

  @override
  Future<Result<List<Member>>> fetchPage(int page, CancelToken? cancelToken) async {
    final result = await _repository.searchMembers(
      query: searchQuery.value,
      stateId: selectedState.value?.id,
      districtId: selectedDistrict.value?.id,
      talukaId: selectedTaluka.value?.id,
      pageNumber: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
    
    if (result is Success<PaginatedResponse<Member>>) {
      return Success(result.data.data);
    } else {
      return Error((result as Error).failure);
    }
  }

  void updateSearch(String query) {
    onSearchChanged(query, (q) => searchQuery.value = q);
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchDebouncer.cancel();
    searchQuery.value = '';
    refreshData(showInitialLoading: true);
  }
}
