import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

class CommitteeDetailsPage extends StatefulWidget {
  const CommitteeDetailsPage({super.key});

  @override
  State<CommitteeDetailsPage> createState() => _CommitteeDetailsPageState();
}

class _CommitteeDetailsPageState extends State<CommitteeDetailsPage> {
  final controller = Get.find<CommitteeController>();
  late CommitteeNode node;

  @override
  void initState() {
    super.initState();
    node = Get.arguments as CommitteeNode;
    controller.loadCommitteeDetail(node.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          node.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => AppStateView(
          state: controller.detailState.value,
          onRetry: () => controller.loadCommitteeDetail(node.id),
          child: _buildContent(controller.committeeDetail.value),
        ),
      ),
    );
  }

  Widget _buildContent(CommitteeDetail? detail) {
    if (detail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // COMMITTEE INFO Section
          _buildSection(
            title: LK.committeeInfo.tr,
            icon: Icons.account_balance,
            child: Column(
              children: [
                _buildInfoRow(LK.nameLabel.tr, detail.name),
                const Divider(height: 12, thickness: 0.5),
                _buildInfoRow(LK.descriptionLabel.tr, detail.description),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ROLES Section
          if (detail.roles.isNotEmpty)
            _buildSection(
              title:
                  '${LK.roles.tr} ${LK.at.tr.toUpperCase()} (${detail.roles.length})',
              icon: Icons.verified_user,
              child: Column(
                children: detail.roles.asMap().entries.map((entry) {
                  final role = entry.value;
                  final isLast = entry.key == detail.roles.length - 1;
                  return Column(
                    children: [
                      _buildRoleTile(
                        _getRoleIcon(role.roleTypeName),
                        role.roleName,
                        role.roleTypeName,
                        role.memberCount,
                      ),
                      if (!isLast) const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          // MEMBERS Section
          _buildSection(
            title: '${LK.membersCount.tr} (${detail.members.length})',
            icon: Icons.groups,
            child: Column(
              children: [
                if (detail.members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(LK.noMembersFound.tr),
                  )
                else
                  Column(
                    children: detail.members.take(3).map((member) {
                      return _buildMemberTile(
                        context,
                        member.memberId,
                        member.name,
                        member.startDate?.split('T').first ?? '',
                        '--', // Reports to not in API yet
                        member.roleName,
                        '',
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.committeeMembers,
                      arguments: node,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LK.showMore.tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'head':
      case 'leadership':
        return Icons.person;
      case 'administrative':
        return Icons.assignment;
      case 'financial':
        return Icons.currency_rupee;
      default:
        return Icons.verified_user;
    }
  }

  Widget _buildSection(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTile(
      IconData icon, String title, String subtitle, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    int memberId,
    String name,
    String since,
    String reportsTo,
      String tag, String imageUrl) {
    return InkWell(
      onTap: () {
        Get.toNamed<void>(AppRouter.memberProfile, arguments: {'memberId': memberId});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.muted,
              child: Icon(Icons.person, color: AppColors.mutedForeground),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12),
                      children: [
                        TextSpan(text: '${LK.sinceColon.tr} '),
                        TextSpan(
                            text: since,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const TextSpan(text: '   |   '),
                        TextSpan(text: '${LK.reportsToColon.tr} '),
                        TextSpan(
                            text: reportsTo,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
