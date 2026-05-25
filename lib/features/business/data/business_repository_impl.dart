import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<List<BusinessCategory>>> getCategories() async {
    final result = await _apiClient.getParsed<List<BusinessCategory>>(
      ApiEndpoints.business,
      fromJsonT: (json) => (json as List)
          .map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    
    if (result is Success<ApiResponse<List<BusinessCategory>>>) {
      return Success(result.data.data ?? []);
    } else {
      return Error((result as Error).failure);
    }
  }
}
