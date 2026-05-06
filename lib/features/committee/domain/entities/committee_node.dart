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

  factory CommitteeNode.fromJson(Map<String, dynamic> json) {
    return CommitteeNode(
      name: json['name'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
      isExpanded: json['isExpanded'] as bool? ?? false,
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((i) => CommitteeNode.fromJson(i as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  List<String> getAllNames() {
    List<String> names = [name];
    for (var child in children) {
      names.addAll(child.getAllNames());
    }
    return names;
  }
}
