class CommitteeNode {
  final String name;
  final int memberCount;
  final List<CommitteeNode> children;
  bool isExpanded;

  CommitteeNode({
    required this.name,
    this.memberCount = 0,
    this.children = const [],
    this.isExpanded = false,
  });

  List<String> getAllNames() {
    List<String> names = [name];
    for (var child in children) {
      names.addAll(child.getAllNames());
    }
    return names;
  }
}

abstract class CommitteeRepository {
  Future<List<CommitteeNode>> getCommittees();
}
