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
    try {
      final response = await _apiClient.getParsed<Samaj>(
        ApiEndpoints.samajDetail,
        fromJsonT: (json) => Samaj.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Sanstha>> getSansthas() async {
    try {
      final response = await _apiClient.getParsed<List<Sanstha>>(
        ApiEndpoints.sansthas,
        fromJsonT: (json) {
          List<dynamic> list = [];
          if (json is List) {
            list = json;
          } else if (json is Map<String, dynamic> && json['data'] is List) {
            list = json['data'] as List<dynamic>;
          }
          return list
              .whereType<Map<String, dynamic>>()
              .map(Sanstha.fromJson)
              .toList();
        },
      );
      return response.data ?? [];
    } catch (_) {
      rethrow;
    }
  }
}
