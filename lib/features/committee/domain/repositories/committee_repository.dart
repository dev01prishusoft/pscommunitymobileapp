import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

abstract class CommitteeRepository {
  Future<List<CommitteeNode>> getCommittees({String? searchQuery});
  Future<CommitteeDetail?> getCommitteeDetail(int id);
}
