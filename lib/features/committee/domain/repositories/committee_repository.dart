import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';

abstract class CommitteeRepository {
  Future<List<CommitteeNode>> getCommittees();
}
