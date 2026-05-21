import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';

class BusinessRepositoryImpl implements BusinessRepository {

  BusinessRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<BusinessCategory>> getCategories() async {
    try {
      final response = await _apiClient.getParsed<List<BusinessCategory>>(
        ApiEndpoints.business,
        fromJsonT: (json) => (json as List)
            .map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }
}
