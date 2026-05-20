import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajRepositoryImpl implements SamajRepository {
  final ApiClient _apiClient;

  SamajRepositoryImpl(this._apiClient);

  @override
  Future<Samaj?> getSamajDetail() async {
    final response = await _apiClient.get(ApiEndpoints.samajDetail);
    final json = response.data as Map<String, dynamic>?;
    if (json == null || json['succeeded'] != true) return null;
    final data = json['data'];
    if (data is! Map<String, dynamic>) return null;
    return Samaj.fromJson(data);
  }

  @override
  Future<List<Sanstha>> getSansthas() async {
    final response = await _apiClient.get(ApiEndpoints.sansthas);

    final json = response.data as Map<String, dynamic>?;
    if (json == null || json['succeeded'] != true) return [];

    final data = json['data'];
    final List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      list = data['data'] as List<dynamic>;
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>() // Skip any non-map entries safely
        .map(Sanstha.fromJson)
        .toList();
  }
}
