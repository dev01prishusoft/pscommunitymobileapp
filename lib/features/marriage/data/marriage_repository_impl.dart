import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/unmarried_count.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/marriage_profile.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  final ApiClient _apiClient;

  MarriageRepositoryImpl(this._apiClient);

  @override
  Future<List<MarriageProfile>> getMatrimonialProfiles() async {
    final response = await _apiClient.getPaginated<MarriageProfile>(
      ApiEndpoints.marriage,
      listKey: 'members',
      fromJsonT: (json) => MarriageProfile.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<List<UnmarriedCount>> getUnmarriedCounts() async {
    final response = await _apiClient.getPaginated<UnmarriedCount>(
      ApiEndpoints.unmarriedCount,
      listKey: 'unMarriedCount',
      fromJsonT: (json) => UnmarriedCount.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
