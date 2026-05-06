import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';

class CommitteeRepositoryImpl implements CommitteeRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  CommitteeRepositoryImpl(this._apiClient);

  @override
  Future<List<CommitteeNode>> getCommittees() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      CommitteeNode(
        name: 'Executive Board',
        memberCount: 5,
        isExpanded: true,
        children: [
          CommitteeNode(name: 'President', memberCount: 1),
          CommitteeNode(name: 'Secretary', memberCount: 1),
          CommitteeNode(name: 'Treasurer', memberCount: 1),
        ],
      ),
      CommitteeNode(
        name: 'Managing Committee',
        memberCount: 15,
        children: [
          CommitteeNode(name: 'Zonal Heads', memberCount: 4),
          CommitteeNode(name: 'Area Leads', memberCount: 11),
        ],
      ),
      CommitteeNode(
        name: 'Standing Committees',
        memberCount: 20,
        children: [
          CommitteeNode(name: 'Education Committee', memberCount: 7),
          CommitteeNode(name: 'Temple Committee', memberCount: 8),
          CommitteeNode(name: 'Finance Sub-Committee', memberCount: 5),
        ],
      ),
      CommitteeNode(name: 'Election Committee', memberCount: 3),
    ];
  }
}
