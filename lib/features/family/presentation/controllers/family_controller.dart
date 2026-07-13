import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/education_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member_address.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyController extends GetxController {
  FamilyController(this._repository);
  final FamilyRepository _repository;

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<FamilyArea> areas = <FamilyArea>[].obs;
  final RxList<Family> families = <Family>[].obs;

  final Rx<AppState> familyListState = AppState.loading.obs;
  final Rx<AppState> memberDetailState = AppState.loading.obs;
  final Rxn<Member> selectedMember = Rxn<Member>();
  final RxList<MemberAddress> memberAddresses = <MemberAddress>[].obs;
  final RxList<EducationModel> memberEducations = <EducationModel>[].obs;

  final RxBool filtersExpanded = true.obs;
  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isTalukasLoading = false.obs;
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> talukas = <DropdownItem>[].obs;
  final Rxn<DropdownItem> selectedState = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedDistrict = Rxn<DropdownItem>();
  final Rxn<DropdownItem> selectedTaluka = Rxn<DropdownItem>();

  Future<void> loadMemberDetails(int memberId) async {
    memberDetailState.value = AppState.loading;
    try {
      final detailFuture = _repository.getMemberDetails(memberId);
      final addressFuture = _repository.getMemberAddresses(memberId);
      final educationFuture = _repository.getMemberEducations(memberId);

      final results = await Future.wait([
        detailFuture,
        addressFuture,
        educationFuture,
      ]);

      selectedMember.value = results[0] as Member;
      memberAddresses.assignAll(results[1] as List<MemberAddress>);
      memberEducations.assignAll(results[2] as List<EducationModel>);

      memberDetailState.value = AppState.data;
    } catch (e) {
      memberDetailState.value = AppState.error;
    }
  }

  Future<void> loadStates() async {
    isStatesLoading.value = true;
    try {
      final results = await _repository.getStates();
      states.assignAll(results);
    } catch (_) {} finally {
      isStatesLoading.value = false;
    }
  }

  Future<void> onStateChanged(DropdownItem? state) async {
    selectedState.value = state;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();
    talukas.clear();

    if (state != null) {
      isDistrictsLoading.value = true;
      try {
        final results = await _repository.getDistricts(state.id);
        districts.assignAll(results);
      } finally {
        isDistrictsLoading.value = false;
      }
    }
  }

  Future<void> loadDistricts(DropdownItem? state) async {
    districts.clear();
    talukas.clear();

    if (state == null) return;

    isDistrictsLoading.value = true;

    try {
      final result = await _repository.getDistricts(state.id);
      districts.assignAll(result);
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> loadTalukas(DropdownItem? district) async {
    talukas.clear();

    if (district == null) return;

    isTalukasLoading.value = true;

    try {
      final result = await _repository.getTalukas(district.id);
      talukas.assignAll(result);
    } finally {
      isTalukasLoading.value = false;
    }
  }
  Future<List<DropdownItem>> fetchDistricts(int stateId) async {
    return _repository.getDistricts(stateId);
  }
  Future<List<DropdownItem>> fetchTalukas(int districtId) async {
    return _repository.getTalukas(districtId);
  }

  Future<void> applyFilters({
    required DropdownItem? state,
    required DropdownItem? district,
    required DropdownItem? taluka,
  }) async {
    selectedState.value = state;
    selectedDistrict.value = district;
    selectedTaluka.value = taluka;

    await loadAreas();
  }

  void searchAreas() {
    loadAreas();
  }

  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;
  int _currentLoadRequestId = 0;

  final RxString memberSearchQuery = ''.obs;
  final RxList<Family> filteredFamilies = <Family>[].obs;

  final tempSelectedState = Rxn<DropdownItem>();
  final tempSelectedDistrict = Rxn<DropdownItem>();
  final tempSelectedTaluka = Rxn<DropdownItem>();

  @override
  void onInit() {
    super.onInit();
    debounce(
      memberSearchQuery,
      (_) => _filterFamilies(),
      time: Duration(milliseconds: 300),
    );
  }

  void _filterFamilies() {
    if (memberSearchQuery.value.isEmpty) {
      filteredFamilies.assignAll(families);
      return;
    }

    final query = memberSearchQuery.value.toLowerCase();
    final results = families
        .map((family) {
          final matchingMembers = family.members.where((member) {
            final name = member.name.toLowerCase();
            final mobile = member.mobileNo?.toLowerCase() ?? '';
            final memberId = member.id.toLowerCase();
            return name.contains(query) ||
                mobile.contains(query) ||
                memberId.contains(query);
          }).toList();

          if (matchingMembers.isEmpty) return null;
          return Family(
            familyName: family.familyName,
            members: matchingMembers,
          );
        })
        .whereType<Family>()
        .toList();

    filteredFamilies.assignAll(results);
  }

  Future<void> loadAreas() async {
    _currentPage = 1;
    hasMore.value = true;
    state.value = AppState.loading;
    areas.clear();
    await _fetchAreas(isRefresh: true);
  }

  Future<void> loadNextPage() async {
    if (!hasMore.value || isNextPageLoading.value) return;
    isNextPageLoading.value = true;
    await _fetchAreas(isRefresh: false);
  }

  Future<void> _fetchAreas({required bool isRefresh}) async {
    final requestId = ++_currentLoadRequestId;

    try {
      final results = await _repository.getFamilyAreas(
        stateId: selectedState.value?.id ?? 0,
        districtId: selectedDistrict.value?.id ?? 0,
        talukaId: selectedTaluka.value?.id ?? 0,
        pageNo: _currentPage,
        pageSize: _pageSize,
      );

      if (requestId != _currentLoadRequestId) return;
      if (isRefresh) {
        areas.clear();
      }

      if (results.isEmpty) {
        hasMore.value = false;

        if (areas.isEmpty) {
          state.value = AppState.empty;
        } else {
          state.value = AppState.data;
        }

        return;
      }

      if (isRefresh) {
        areas.assignAll(List.unmodifiable(results));
      } else {
        areas.assignAll(List.unmodifiable([...areas, ...results]));
      }

      _currentPage++;

      if (results.length < _pageSize) {
        hasMore.value = false;
      }

      state.value = AppState.data;
    } catch (e) {
      if (requestId != _currentLoadRequestId) return;
      if (isRefresh) {
        state.value = AppState.error;
      }
    } finally {
      if (requestId == _currentLoadRequestId) {
        isNextPageLoading.value = false;
      }
    }
  }

  int _familiesPage = 1;
  final RxBool hasMoreFamilies = true.obs;
  final RxBool isNextPageFamiliesLoading = false.obs;

  Future<void> loadFamilies(int areaId, {bool isRefresh = true}) async {
    if (isRefresh) {
      _familiesPage = 1;
      hasMoreFamilies.value = true;
      familyListState.value = AppState.loading;
      families.clear();
    } else {
      if (!hasMoreFamilies.value || isNextPageFamiliesLoading.value) return;
      isNextPageFamiliesLoading.value = true;
    }

    try {
      final results = await _repository.getFamiliesByArea(
        areaId,
        pageNo: _familiesPage,
        pageSize: _pageSize,
      );

      if (results.isEmpty) {
        hasMoreFamilies.value = false;
        if (families.isEmpty) {
          familyListState.value = AppState.empty;
        } else {
          familyListState.value = AppState.data;
        }
        isNextPageFamiliesLoading.value = false;
        return;
      }

      if (isRefresh) {
        families.assignAll(results);
      } else {
        families.addAll(results);
      }

      _familiesPage++;
      if (results.length < _pageSize) {
        hasMoreFamilies.value = false;
      }

      _filterFamilies();
      familyListState.value = filteredFamilies.isEmpty
          ? AppState.empty
          : AppState.data;
    } catch (e) {
      if (isRefresh) {
        familyListState.value = AppState.error;
      }
    } finally {
      isNextPageFamiliesLoading.value = false;
    }
  }

  Future<void> resetFilters() async {
    tempSelectedState.value = null;
    tempSelectedDistrict.value = null;
    tempSelectedTaluka.value = null;

    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    districts.clear();

    talukas.clear();
    await loadAreas();
  }

  String _formatDouble(double? value) {
    if (value == null) return '0';
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }

  String formatGender(Member member) => (member.genderName ?? LK.na).tr;
  String formatBloodGroup(Member member) => member.bloodGroupName ?? LK.na;
  String formatHeight(Member member) => '${_formatDouble(member.height)} cm';
  String formatWeight(Member member) => '${_formatDouble(member.weight)} kg';
  String formatMotherFather(Member member) => member.motherFatherName ?? LK.na;
  String formatOccupation(Member member) =>
      member.occupationName ?? member.occupationTypeName ?? LK.na;
  String formatOccupationArea(Member member) =>
      member.occupationAreaName ?? LK.na;
  String formatMaritalStatus(Member member) =>
      (member.maritalStatusName ?? LK.na).tr;
  String formatMobileNo(Member member) => member.mobileNo ?? LK.na;
  String formatEmergencyContact(Member member) =>
      member.emergencyContactNo ?? LK.na;
  String formatGotra(Member member) => member.gotraName ?? LK.na;
  String formatEmail(Member member) => member.emailAddress ?? LK.na;
  String formatIncome(Member member) =>
      '₹${_formatDouble(member.monthlyIncome)}';
  String formatAge(Member member) =>
      member.age > 0 ? '${member.age} ${LK.ageYears.tr}' : LK.na;

  Future<void> launchSafeUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (urlString.startsWith('tel:')) {
        final String number = urlString.replaceFirst('tel:', '');
        final Uri telUri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      } else {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
    }
  }

  String getFormattedDateOfBirth(Member member) {
    if (member.dateOfBirth == null) return LK.na;
    String dobStr = '';
    try {
      final dob = DateTime.parse(member.dateOfBirth!);
      dobStr =
          '${dob.day.toString().padLeft(2, '0')} / ${dob.month.toString().padLeft(2, '0')} / ${dob.year}';
    } catch (_) {
      final parts = member.dateOfBirth!.split('T')[0].split('-');
      if (parts.length == 3) {
        dobStr = '${parts[2]} / ${parts[1]} / ${parts[0]}';
      } else {
        dobStr = member.dateOfBirth!;
      }
    }

    return dobStr;
  }

  String getFormattedBirthTime(Member member) {
    if (member.dateOfBirthTime == null || member.dateOfBirthTime!.isEmpty) {
      return LK.na;
    }
    final parts = member.dateOfBirthTime!.split(':');
    if (parts.length >= 2) {
      try {
        final int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);
        final String amPm = hour >= 12 ? 'PM' : 'AM';
        final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final String displayMinute = minute.toString().padLeft(2, '0');
        return '$displayHour:$displayMinute $amPm';
      } catch (_) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return member.dateOfBirthTime!;
  }
}
