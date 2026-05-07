import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';

class CommitteeRepositoryImpl implements CommitteeRepository {
  CommitteeRepositoryImpl(this._apiClient);
  
  final ApiClient _apiClient;

  @override
  Future<List<CommitteeNode>> getCommittees() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.committees,
        queryParameters: {
          'PageNumber': 1,
          'PageSize': 100, // Load all for tree structure
        },
      );

      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) return [];

      final dataObj = json['data'] as Map<String, dynamic>? ?? {};
      final list = dataObj['committees'] as List? ?? [];

      return list.map((e) => CommitteeNode.fromJson(e as Map<String, dynamic>)).toList();
    } on Exception catch (e) {
      AppLogger.e('GetCommittees Error', e);
      rethrow;
    }
  }
}
