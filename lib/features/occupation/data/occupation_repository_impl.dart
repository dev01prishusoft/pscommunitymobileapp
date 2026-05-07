import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

class OccupationRepositoryImpl implements OccupationRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  OccupationRepositoryImpl(this._apiClient);

  @override
  Future<List<OccupationItem>> getOccupations({int? occupationTypeId}) async {
    final queryParameters = <String, dynamic>{
      if (occupationTypeId != null) 'occupationTypeId': occupationTypeId,
      'pageNumber': 1,
      'pageSize': 100,
    };

    final response = await _apiClient.get(
      '/api/v1/Occupation/list',
      queryParameters: queryParameters,
    );

    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] != true) return [];

    final dataObj = json['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['data'] as List? ?? [];

    return list.map((e) => OccupationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<OccupationItem> getOccupationDetails(int id) async {
    final response = await _apiClient.get('/api/v1/Occupation/$id');

    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] != true) {
      throw Exception(json['message'] ?? 'Failed to load occupation details');
    }

    final data = json['data'] as Map<String, dynamic>;
    return OccupationItem.fromJson(data);
  }
}
