import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class OccupationRepositoryImpl implements OccupationRepository {
  OccupationRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<OccupationItem>> getOccupations({
    int? occupationTypeId,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      if (occupationTypeId != null && occupationTypeId != 0)
        'occupationTypeId': occupationTypeId,
      if (search != null && search.isNotEmpty) 'search': search,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    try {
      final response = await _apiClient.getPaginated<OccupationItem>(
        ApiEndpoints.occupations,
        queryParameters: queryParameters,
        listKey: 'occupations',
        fromJsonT: (json) =>
            OccupationItem.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetOccupations Error', e, stack);
      return [];
    }
  }

  @override
  Future<OccupationItem> getOccupationDetails(int id) async {
    final response = await _apiClient.getParsed<OccupationItem>(
      '${ApiEndpoints.occupationDetail}/$id',
      fromJsonT: (json) =>
          OccupationItem.fromJson(json as Map<String, dynamic>),
    );
    return response.dataOrNull!.data!;
  }

  @override
  Future<List<DropdownItem>> getOccupationDropdown() async {
    try {
      final response = await _apiClient.getParsed<List<DropdownItem>>(
        ApiEndpoints.occupationDropdown,
        fromJsonT: (json) => _parseDropdownListData(json),
      );
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetOccupationDropdown Error', e, stack);
      return [];
    }
  }

  @override
  Future<List<Member>> getOccupationMembers({
    required int occupationId,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'occupationId': occupationId,
      if (search != null && search.isNotEmpty) 'search': search,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    try {
      final response = await _apiClient.getPaginated<Member>(
        ApiEndpoints.memberUsingOccupation,
        queryParameters: queryParameters,
        listKey: 'members',
        fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data ?? [];
    } catch (e, stack) {
      AppLogger.e('GetOccupationMembers Error', e, stack);
      return [];
    }
  }

  List<DropdownItem> _parseDropdownListData(dynamic rawData) {
    List<dynamic> list = [];

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      list =
          (rawData['data'] ?? rawData['occupations'] ?? <dynamic>[]) as List? ??
          [];
    }

    return list
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
