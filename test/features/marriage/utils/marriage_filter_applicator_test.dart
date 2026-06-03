import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/marriage/utils/marriage_filter_applicator.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

void main() {
  List<Member> members = [];

  setUp(() {
    members = [
      Member(
        memberId: 1,
        firstName: 'John',
        lastName: 'Doe',
        apiAge: 25,
        height: 170,
        gotraName: 'Kashyap',
        maritalStatusName: 'Unmarried',
        occupationStateName: 'Gujarat',
        occupationDistrictName: 'Ahmedabad',
        occupationTalukaName: 'City',
        occupationAreaName: 'Bapunagar',
        educationName: 'B.E.',
        occupationName: 'Software Engineer',
        monthlyIncome: 150000,
      ),
      Member(
        memberId: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        apiAge: 30,
        height: 160,
        gotraName: 'Bharadwaj',
        maritalStatusName: 'Divorced',
        occupationStateName: 'Maharashtra',
        occupationDistrictName: 'Mumbai',
        occupationTalukaName: 'Andheri',
        occupationAreaName: 'West',
        educationName: 'MBA',
        occupationName: 'Manager',
        monthlyIncome: 300000,
      ),
      Member(
        memberId: 3,
        firstName: 'Alice',
        lastName: 'Johnson',
        apiAge: 28,
        height: 165,
        gotraName: 'Kashyap',
        maritalStatusName: 'Unmarried',
        occupationStateName: 'Gujarat',
        occupationDistrictName: 'Surat',
        occupationTalukaName: 'Choryasi',
        occupationAreaName: 'Adajan',
        educationName: 'B.Com',
        occupationName: 'Accountant',
        monthlyIncome: 50000,
      ),
    ];
  });

  test('Empty filter returns all members', () {
    final state = MarriageFilterState();
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 3);
  });

  test('Filter by search query (name)', () {
    final state = MarriageFilterState(searchQuery: 'jane');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'Jane');
  });

  test('Filter by age range', () {
    final state = MarriageFilterState(selectedAgeFrom: '26', selectedAgeTo: '30');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 2);
    expect(result.any((m) => m.firstName == 'John'), false);
  });

  test('Filter by height range', () {
    final state = MarriageFilterState(selectedHeightFrom: '150 cm', selectedHeightTo: '162 cm');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'Jane');
  });

  test('Filter by Gotra', () {
    final state = MarriageFilterState(selectedGotra: 'Kashyap');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 2);
  });

  test('Exclude same Gotra', () {
    final state = MarriageFilterState(excludeSameGotra: true, myGotra: 'Kashyap');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'Jane'); // Only Bharadwaj left
  });

  test('Filter by marital status', () {
    final state = MarriageFilterState(selectedMaritalStatus: 'Unmarried');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 2);
  });

  test('Filter by location (State)', () {
    final state = MarriageFilterState(selectedState: 'Maharashtra');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'Jane');
  });

  test('Filter by education', () {
    final state = MarriageFilterState(selectedEducation: 'B.E.');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'John');
  });

  test('Filter by occupation', () {
    final state = MarriageFilterState(selectedOccupation: 'Manager');
    final result = MarriageFilterApplicator.apply(members, state);
    expect(result.length, 1);
    expect(result.first.firstName, 'Jane');
  });

  test('Filter by income range', () {
    // John: 150000, Jane: 300000, Alice: 50000
    final state1 = MarriageFilterState(selectedIncomeFrom: '1 Lakh');
    final result1 = MarriageFilterApplicator.apply(members, state1);
    expect(result1.length, 2); // John, Jane (min 1L, no max)
    expect(result1.any((m) => m.firstName == 'Alice'), false);

    final state2 = MarriageFilterState(selectedIncomeFrom: '1 Lakh', selectedIncomeTo: '5 Lakh');
    final result2 = MarriageFilterApplicator.apply(members, state2);
    expect(result2.length, 2); // John, Jane
    
    final state3 = MarriageFilterState(selectedIncomeTo: '2 Lakh');
    final result3 = MarriageFilterApplicator.apply(members, state3);
    expect(result3.length, 2); // John, Alice (max 2L)
  });
}
