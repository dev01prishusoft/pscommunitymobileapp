import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MemberRepositoryImpl implements MemberRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  MemberRepositoryImpl(this._apiClient);

  @override
  Future<List<Member>> getMembers() async {
    return searchMembers(pageNumber: 1, pageSize: 50);
  }

  @override
  Future<List<Member>> searchMembers({
    String? query,
    int? genderId,
    bool? lookingForMarriage,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (query != null && query.isNotEmpty) 'search': query,
      if (genderId != null) 'genderId': genderId,
      if (lookingForMarriage != null) 'lookingForMarriage': lookingForMarriage,
    };

    final response = await _apiClient.getPaginated<Member>(
      '/api/v1/member/MemberSearch',
      queryParameters: queryParameters,
      listKey: 'members',
      fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
    );

    return response.data;
  }
}
