import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

abstract class CommitteeRepository {
  Future<List<CommitteeNode>> getCommittees({
    String? searchQuery,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<CommitteeDetail?> getCommitteeDetail(int id);
}
