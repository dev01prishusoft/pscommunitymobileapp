import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  final controller = Get.find<CommitteeController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.text = controller.searchQuery.value;
    controller.clearSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          LK.committees.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: controller.onSearchChanged,
              onTapOutside: (event) => _focusNode.unfocus(),
              decoration: InputDecoration(
                hintText: LK.searchCommittees.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          controller.onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => AppStateView(
              state: controller.state.value,
              onRetry: controller.loadCommittees,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.committees.length,
                itemBuilder: (context, index) {
                  return _CommitteeCard(node: controller.committees[index]);
                },
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _CommitteeCard extends StatelessWidget {
  final CommitteeNode node;

  const _CommitteeCard({required this.node});

  @override
  Widget build(BuildContext context) {
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
      child: Obx(() => Column(
        children: [
          _CommitteeTile(node: node, isRoot: true),
          if (node.isExpanded && node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChildrenList(children: node.children, depth: 1),
            ),
        ],
      )),
    );
  }
}

class _ChildrenList extends StatelessWidget {
  final List<CommitteeNode> children;
  final int depth;

  const _ChildrenList({required this.children, this.depth = 1});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            return Obx(() => Column(
              children: [
                _CommitteeTile(node: child, depth: depth),
                if (child.isExpanded && child.children.isNotEmpty)
                  _ChildrenList(children: child.children, depth: depth + 1),
              ],
            ));
          }).toList(),
        ),
      ],
    );
  }
}

class _CommitteeTile extends StatelessWidget {
  final CommitteeNode node;
  final int depth;
  final bool isRoot;

  const _CommitteeTile({
    required this.node,
    this.depth = 0,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed<void>(
          AppRouter.committeeDetails,
          arguments: node,
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
            if (node.children.isNotEmpty)
              IconButton(
                onPressed: () => Get.find<CommitteeController>().toggleNode(node),
                icon: Icon(
                  node.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name,
                    style: TextStyle(
                      fontWeight: isRoot ? FontWeight.bold : FontWeight.w600,
                      fontSize: isRoot ? 16 : 14,
                      color: AppColors.secondary,
                    ),
                  ),
                  if (node.memberCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${LK.membersCount.tr}: ${node.memberCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
