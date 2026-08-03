import 'package:get/get.dart';

class CommitteeNode {
  CommitteeNode({
    required this.id,
    required this.name,
    this.memberCount = 0,
    this.parentId,
    this.children = const [],
    bool isExpanded = true,
  }) : _isExpanded = isExpanded.obs;

  factory CommitteeNode.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    int? parseParentId(Map<String, dynamic> json) {
      final val =
          json['parentCommitteeId'] ??
          json['parentId'] ??
          json['ParentCommitteeId'] ??
          json['parent_id'];

      if (val == null || val == 0 || val == '0') return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    final id = parseId(
      json['id'] ?? json['Id'] ?? json['committeeId'] ?? json['CommitteeId'],
    );
    final parentId = parseParentId(json);

    return CommitteeNode(
      id: id,
      name:
          (json['committeeName'] ?? json['name'] ?? json['CommitteeName'])
              as String? ??
          '',
      memberCount:
          (json['totalMembers'] ?? json['memberCount'] ?? json['MemberCount'])
              as int? ??
          0,
      parentId: parentId,
      isExpanded: true,
      children: [],
    );
  }
  final int id;
  final String name;
  final int memberCount;
  final int? parentId;
  final List<CommitteeNode> children;
  final RxBool _isExpanded;
  bool get isExpanded => _isExpanded.value;
  set isExpanded(bool value) => _isExpanded.value = value;

  CommitteeNode copyWith({
    int? id,
    String? name,
    int? memberCount,
    int? parentId,
    List<CommitteeNode>? children,
    bool? isExpanded,
  }) {
    return CommitteeNode(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCount: memberCount ?? this.memberCount,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  List<String> getAllNames() {
    final List<String> names = [name];
    for (var child in children) {
      names.addAll(child.getAllNames());
    }
    return names;
  }
}
