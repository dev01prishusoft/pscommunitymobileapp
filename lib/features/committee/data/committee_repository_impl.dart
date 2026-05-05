import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class CommitteeRepositoryImpl implements CommitteeRepository {
  final ApiClient _apiClient;

  CommitteeRepositoryImpl(this._apiClient);

  @override
  Future<List<CommitteeNode>> getCommittees() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      CommitteeNode(
        name: 'Executive Board',
        memberCount: 5,
        isExpanded: true,
        children: [
          CommitteeNode(
            name: 'Managing Committee',
            memberCount: 12,
            isExpanded: true,
            children: [
              CommitteeNode(
                name: 'Finance Sub-Committee',
                memberCount: 4,
              ),
            ],
          ),
          CommitteeNode(
            name: 'Election Committee',
            memberCount: 5,
          ),
        ],
      ),
      CommitteeNode(
        name: 'Standing Committees',
        memberCount: 0,
        isExpanded: true,
        children: [
          CommitteeNode(
            name: 'Temple Committee',
            memberCount: 8,
          ),
          CommitteeNode(
            name: 'Education Committee',
            memberCount: 6,
          ),
        ],
      ),
    ];
  }
}
