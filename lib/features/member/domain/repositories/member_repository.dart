import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getMembers();
  
  Future<List<Member>> searchMembers({
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
