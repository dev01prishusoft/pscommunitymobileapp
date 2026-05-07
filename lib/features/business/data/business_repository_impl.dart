import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final ApiClient _apiClient;

  BusinessRepositoryImpl(this._apiClient);

  @override
  Future<List<BusinessCategory>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.business);
      final json = response.data as Map<String, dynamic>;
      
      if (json['succeeded'] == true) {
        final data = json['data'] as List<dynamic>;
        return data.map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
