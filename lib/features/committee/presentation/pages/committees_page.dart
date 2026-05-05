import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  final List<CommitteeNode> _committees = [
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
      memberCount: 0, // Not explicitly shown in image for parent
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Committees'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _committees.length,
        itemBuilder: (context, index) {
          return _buildCommitteeCard(_committees[index]);
        },
      ),
    );
  }

  Widget _buildCommitteeCard(CommitteeNode node) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCommitteeTile(node, isRoot: true),
          if (node.isExpanded && node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChildrenList(node.children, depth: 1),
            ),
        ],
      ),
    );
  }

  Widget _buildChildrenList(List<CommitteeNode> children, {int depth = 1}) {
    return Stack(
      children: [
        // Vertical line for tree structure
        Positioned(
          left: 32.0 * depth - 16,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
        ),
        Column(
          children: children.map((child) {
            return Column(
              children: [
                _buildCommitteeTile(child, depth: depth),
                if (child.isExpanded && child.children.isNotEmpty)
                  _buildChildrenList(child.children, depth: depth + 1),
              ],
            );
          }).toList(),
        ), 
      ],
    );
  }

  Widget _buildCommitteeTile(CommitteeNode node, {int depth = 0, bool isRoot = false}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.committeeDetails,
          arguments: node.getAllNames(),
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 16 + (depth * 32.0),
          right: 16,
          top: 16,
          bottom: 16,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: node.children.isEmpty
                  ? null
                  : () {
                      setState(() {
                        node.isExpanded = !node.isExpanded;
                      });
                    },
              child: Icon(
                node.children.isEmpty
                    ? Icons.chevron_right
                    : (node.isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
                color: const Color(0xFF0066CC),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name.tr,
                    style: TextStyle(
                      fontWeight: isRoot ? FontWeight.bold : FontWeight.w600,
                      fontSize: isRoot ? 16 : 14,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (node.memberCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${'Members'.tr}: ${node.memberCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF0066CC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

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
