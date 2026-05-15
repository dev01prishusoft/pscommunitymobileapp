import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

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
      // Treat 0 as 'All' (null)
      if (occupationTypeId != null && occupationTypeId != 0)
        'occupationTypeId': occupationTypeId,
      if (search != null && search.isNotEmpty) 'search': search,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    try {
      final response = await _apiClient.get(
        ApiEndpoints.occupations,
        queryParameters: queryParameters,
      );

      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) return [];

      // Handle nested data structures robustly
      List<dynamic> list = [];
      final rawData = json['data'];

      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map<String, dynamic>) {
        // Handle { data: { data: [...] } } or { data: [...] }
        list =
            (rawData['data'] ?? rawData['occupations'] ?? <dynamic>[])
                as List? ??
            [];
      }

      return list
          .map((e) => OccupationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      AppLogger.e('GetOccupations Error', e, stack);
      return [];
    }
  }

  @override
  Future<OccupationItem> getOccupationDetails(int id) async {
    final response = await _apiClient.get('${ApiEndpoints.occupations}/$id');

    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] != true) {
      throw Exception(json['message'] ?? 'Failed to load occupation details');
    }

    final data = json['data'] as Map<String, dynamic>;
    return OccupationItem.fromJson(data);
  }

  @override
  Future<List<DropdownItem>> getOccupationDropdown() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.occupationDropdown);
      return _parseDropdownList(response.data);
    } catch (e, stack) {
      AppLogger.e('GetOccupationDropdown Error', e, stack);
      return [];
    }
  }

  List<DropdownItem> _parseDropdownList(dynamic responseData) {
    if (responseData == null) return [];
    
    final json = responseData as Map<String, dynamic>;
    if (json['succeeded'] != true) return [];

    final rawData = json['data'];
    List<dynamic> list = [];

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      // Check for nested 'data' or specific list keys
      list =
          (rawData['data'] ?? rawData['occupations'] ?? <dynamic>[]) as List? ??
          [];
      // If still empty, check if rawData itself was the list but was parsed as a map (unlikely but safe)
      if (list.isEmpty && rawData.isNotEmpty && !rawData.containsKey('data')) {
        // If rawData is not empty and doesn't contain 'data', it might be a single object or different format
      }
    }

    return list
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

