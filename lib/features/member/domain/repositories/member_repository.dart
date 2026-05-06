import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getMembers();
}
