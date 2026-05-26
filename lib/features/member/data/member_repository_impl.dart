import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<PaginatedResponse<Member>>> getMembers() async {
    return searchMembers(pageNumber: 1, pageSize: 50);
  }

  @override
  Future<Result<PaginatedResponse<Member>>> searchMembers({
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (query != null && query.isNotEmpty) 'search': query,
      if (genderId != null) 'genderId': genderId,
      if (lookingForMarriage != null) 'lookingForMarriage': lookingForMarriage,
    };

    return await _apiClient.getPaginated<Member>(
      '/api/v1/member/MemberSearch',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      listKey: 'members',
      fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<bool>> updateProfile(Member member) async {
    final result = await _apiClient.putParsed<bool>(
      '/api/v1/member',
      data: member.toJson(),
      fromJsonT: (json) => true,
    );
    if (result.isSuccess) {
      return Success(result.dataOrNull?.data ?? true);
    } else {
      return Error(result.failureOrNull!);
    }
  }
}
