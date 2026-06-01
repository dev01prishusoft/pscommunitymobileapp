import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

abstract class MemberRepository {
  Future<Result<PaginatedResponse<Member>>> getMembers();

  Future<Result<PaginatedResponse<Member>>> searchMembers({
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  });

  Future<Result<bool>> updateProfile(Member member);

  Future<Result<bool>> deleteAccount(int id);
}
