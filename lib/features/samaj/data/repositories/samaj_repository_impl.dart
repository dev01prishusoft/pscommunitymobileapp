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
    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] == true) {
      return Samaj.fromJson(json['data'] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<List<Sanstha>> getSansthas() async {
    final response = await _apiClient.get(ApiEndpoints.sansthas);
    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] == true) {
      final data = json['data'];
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }
      return list.map((e) => Sanstha.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
