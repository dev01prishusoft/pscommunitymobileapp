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
    final response = await _apiClient.get(ApiEndpoints.marriage);
    
    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] != true) return [];

    final dataObj = json['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['members'] as List? ?? [];

    return list.map((e) => MarriageProfile.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<UnmarriedCount>> getUnmarriedCounts() async {
    final response = await _apiClient.get(ApiEndpoints.unmarriedCount);
    
    final json = response.data as Map<String, dynamic>;
    if (json['succeeded'] != true) return [];

    final dataObj = json['data'] as Map<String, dynamic>? ?? {};
    final list = dataObj['unMarriedCount'] as List? ?? [];

    return list.map((e) => UnmarriedCount.fromJson(e as Map<String, dynamic>)).toList();
  }
}
