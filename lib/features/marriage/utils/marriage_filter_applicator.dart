import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MarriageFilterState {
  MarriageFilterState({
    this.searchQuery = '',
    this.selectedAgeFrom = '18',
    this.selectedAgeTo = '60',
    this.selectedHeightFrom = '120 cm',
    this.selectedHeightTo = '210 cm',
    this.selectedGotra = 'Any',
    this.selectedMaritalStatus = 'All',
    this.selectedState = 'All',
    this.selectedDistrict = 'All',
    this.selectedTaluka = 'All',
    this.selectedArea = 'All',
    this.selectedStateId,
    this.selectedDistrictId,
    this.selectedTalukaId,
    this.selectedEducation = 'Any',
    this.selectedOccupation = 'Any',
    this.selectedIncomeFrom = '',
    this.selectedIncomeTo = '',
    this.excludeSameGotra = false,
    this.myGotra,
  });

  final String searchQuery;
  final String selectedAgeFrom;
  final String selectedAgeTo;
  final String selectedHeightFrom;
  final String selectedHeightTo;
  final String selectedGotra;
  final String selectedMaritalStatus;
  final String selectedState;
  final String selectedDistrict;
  final String selectedTaluka;
  final String selectedArea;
  final int? selectedStateId;
  final int? selectedDistrictId;
  final int? selectedTalukaId;
  final String selectedEducation;
  final String selectedOccupation;
  final String selectedIncomeFrom;
  final String selectedIncomeTo;
  final bool excludeSameGotra;
  final String? myGotra;
}

class MarriageFilterApplicator {
  static List<Member> apply(List<Member> members, MarriageFilterState filters) {
    var result = members;

    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      result = result.where((m) {
        final fullName = m.fullName.toLowerCase();
        final occupation = m.occupation.toLowerCase();
        final age = m.age.toString();
        final memberNo = (m.memberNo ?? '').toLowerCase();
        final mobile = (m.mobileNo ?? '').toLowerCase();
        return fullName.contains(query) ||
            occupation.contains(query) ||
            age.contains(query) ||
            memberNo.contains(query) ||
            mobile.contains(query);
      }).toList();
    }

    if (filters.selectedAgeFrom != '18' || filters.selectedAgeTo != '60') {
      final minAge = int.tryParse(filters.selectedAgeFrom) ?? 18;
      final maxAge = int.tryParse(filters.selectedAgeTo) ?? 60;
      result = result.where((m) => m.age >= minAge && m.age <= maxAge).toList();
    }

    if (filters.selectedHeightFrom != '120 cm' || filters.selectedHeightTo != '210 cm') {
      final minH = int.tryParse(filters.selectedHeightFrom.replaceAll(' cm', '')) ?? 120;
      final maxH = int.tryParse(filters.selectedHeightTo.replaceAll(' cm', '')) ?? 210;
      result = result.where((m) {
        final h = m.height ?? 0;
        return h >= minH && h <= maxH;
      }).toList();
    }

    if (filters.selectedGotra != 'Any') {
      final selectedLower = filters.selectedGotra.trim().toLowerCase();
      result = result.where((m) {
        return m.gotra.trim().toLowerCase() == selectedLower;
      }).toList();
    }

    if (filters.excludeSameGotra && filters.myGotra != null && filters.myGotra!.isNotEmpty) {
      final myGotraLower = filters.myGotra!.trim().toLowerCase();
      result = result.where((m) => m.gotra.trim().toLowerCase() != myGotraLower).toList();
    }

    if (filters.selectedMaritalStatus != 'All') {
      result = result.where((m) {
        final statusRaw = (m.maritalStatusName ?? '').toLowerCase().replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
        final selectedRaw = filters.selectedMaritalStatus.toLowerCase().replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
        if (selectedRaw == 'unmarried' || selectedRaw == 'single') {
          return statusRaw == 'unmarried' || statusRaw == 'single';
        }
        return statusRaw == selectedRaw;
      }).toList();
    }

    if (filters.selectedState != 'All') {
      if (filters.selectedStateId != null) {
        result = result.where((m) => m.stateId == filters.selectedStateId).toList();
      } else {
        result = result.where((m) => (m.occupationStateName ?? '') == filters.selectedState).toList();
      }
    }

    if (filters.selectedDistrict != 'All') {
      if (filters.selectedDistrictId != null) {
        result = result.where((m) => m.districtId == filters.selectedDistrictId).toList();
      } else {
        result = result.where((m) => (m.occupationDistrictName ?? '') == filters.selectedDistrict).toList();
      }
    }

    if (filters.selectedTaluka != 'All') {
      if (filters.selectedTalukaId != null) {
        result = result.where((m) => m.talukaId == filters.selectedTalukaId).toList();
      } else {
        result = result.where((m) => (m.occupationTalukaName ?? '') == filters.selectedTaluka).toList();
      }
    }

    if (filters.selectedArea != 'All') {
      result = result.where((m) => m.area == filters.selectedArea).toList();
    }

    if (filters.selectedEducation != 'Any') {
      result = result.where((m) => (m.educationName ?? '').contains(filters.selectedEducation)).toList();
    }

    if (filters.selectedOccupation != 'Any') {
      result = result.where((m) => (m.occupationName ?? '') == filters.selectedOccupation || (m.occupationTypeName ?? '') == filters.selectedOccupation).toList();
    }

    int? getIncomeValue(String selection) {
      if (selection.isEmpty) return null;
      return int.tryParse(selection);
    }

    int? minIncome = getIncomeValue(filters.selectedIncomeFrom);
    int? maxIncome = getIncomeValue(filters.selectedIncomeTo);

    if (minIncome != null && maxIncome != null && minIncome > maxIncome) {
      // Invalid range, ignore income filter
      minIncome = null;
      maxIncome = null;
    }

    if (minIncome != null || maxIncome != null) {
      result = result.where((m) {
        final income = m.monthlyIncome ?? 0;
        if (minIncome != null && income < minIncome) return false;
        if (maxIncome != null && income > maxIncome) return false;
        return true;
      }).toList();
    }

    return result.toList();
  }
}
