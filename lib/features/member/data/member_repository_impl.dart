import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MemberRepositoryImpl implements MemberRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  MemberRepositoryImpl(this._apiClient);

  @override
  Future<List<Member>> getMembers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const Member(
        name: 'Rajesh Kumar Patel',
        info: 'Male • 32 yrs • Married',
        location: 'Ahmedabad',
      ),
      const Member(
        name: 'Suresh Bhai Mehta',
        info: 'Male • 55 yrs • Married',
        location: 'Vadodara',
      ),
      const Member(
        name: 'Priya Ben Shah',
        info: 'Female • 28 yrs • Unmarried',
        location: 'Surat',
      ),
      const Member(
        name: 'Amit Kumar Joshi',
        info: 'Male • 40 yrs • Married',
        location: 'Rajkot',
      ),
      const Member(
        name: 'Meena Kumari Patel',
        info: 'Female • 50 yrs • Widow',
        location: 'Ahmedabad',
      ),
    ];
  }
}
