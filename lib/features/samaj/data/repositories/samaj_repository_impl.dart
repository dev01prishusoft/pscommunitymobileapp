import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajRepositoryImpl implements SamajRepository {
  SamajRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Samaj?> getSamajDetail() async {
    try {
      final response = await _apiClient.getParsed<Samaj>(
        ApiEndpoints.samajDetail,
        fromJsonT: (json) => Samaj.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data;
    } catch (_) {
      return null;
    }
  }
}
