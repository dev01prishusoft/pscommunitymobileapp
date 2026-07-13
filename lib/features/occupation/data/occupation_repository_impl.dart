import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';

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
    };

    try {
      final response = await _apiClient.getPaginated<OccupationItem>(
        ApiEndpoints.occupations,
        queryParameters: queryParameters,
        listKey: 'data',
        fromJsonT: (json) =>
            OccupationItem.fromJson(json as Map<String, dynamic>),
      );
      
      var data = response.dataOrNull?.data ?? [];

      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        data = data.where((e) => e.name.toLowerCase().contains(query)).toList();
      }

      final startIndex = (pageNumber - 1) * pageSize;
      if (startIndex >= data.length) {
        return [];
      }
      final endIndex = startIndex + pageSize;
      return data.sublist(
        startIndex,
        endIndex > data.length ? data.length : endIndex,
      );
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
