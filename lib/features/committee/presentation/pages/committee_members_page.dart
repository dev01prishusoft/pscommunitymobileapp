import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CommitteeMembersPage extends StatefulWidget {
  const CommitteeMembersPage({super.key});

  @override
  State<CommitteeMembersPage> createState() => _CommitteeMembersPageState();
}

class _CommitteeMembersPageState extends State<CommitteeMembersPage> {
  String _selectedRole = 'All';
  String _selectedCommittee = 'All';

  final List<Map<String, dynamic>> _committeeData = [
    {
      'role': 'PRESIDENT',
      'count': 2,
      'isExpanded': true,
      'members': [
        {
          'name': 'Rajesh Patel',
          'committee': 'Managing Committee',
          'since': 'Jan 2024',
          'until': 'Dec 2027',
          'reportsTo': 'Amit Mehta (Treasurer)',
        },
        {
          'name': 'Neha Kapoor',
          'committee': 'Executive Board',
          'since': 'Jan 2024',
          'until': 'Dec 2026',
          'reportsTo': 'Amit Mehta (Treasurer)',
        },
      ]
    },
    {
      'role': 'SECRETARY',
      'count': 3,
      'isExpanded': true,
      'members': [
        {
          'name': 'Meera Shah',
          'committee': 'Managing Committee',
          'since': 'Jan 2024',
          'until': 'Dec 2027',
          'reportsTo': 'Rajesh Patel (President)',
        },
        {
          'name': 'Kiran Shah',
          'committee': 'Election Committee',
          'since': 'Feb 2024',
          'until': 'Dec 2025',
          'reportsTo': 'Rajesh Patel (President)',
        },
      ]
    },
    {
      'role': 'TREASURER',
      'count': 1,
      'isExpanded': true,
      'members': [
        {
          'name': 'Amit Mehta',
          'committee': 'Managing Committee',
          'since': 'Jan 2024',
          'until': 'Dec 2027',
          'reportsTo': 'Rajesh Patel (President)',
        },
      ]
    },
  ];

  List<String> get _allRoles => ['All', ..._committeeData.map((g) => g['role'] as String).toSet()];
  List<String> get _allCommittees => ['All', ..._committeeData.expand((g) => (g['members'] as List).map((m) => m['committee'] as String)).toSet()];

  List<Map<String, dynamic>> get _filteredCommitteeData {
    return _committeeData
        .where((group) => _selectedRole == 'All' || group['role'] == _selectedRole)
        .map((group) {
      final List<Map<String, dynamic>> members =
          List<Map<String, dynamic>>.from(group['members']);
      final filteredMembers = members.where((member) {
        final matchesCommittee = _selectedCommittee == 'All' ||
            member['committee'] == _selectedCommittee;
        return matchesCommittee;
      }).toList();

      return {
        ...group,
        'members': filteredMembers,
        'count': filteredMembers.length,
      };
    }).where((group) => (group['members'] as List).isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredCommitteeData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Committee Members'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Role:'.tr,
                    _selectedRole,
                    _allRoles,
                    (val) => setState(() => _selectedRole = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    'Committee:'.tr,
                    _selectedCommittee,
                    _allCommittees,
                    (val) => setState(() => _selectedCommittee = val!),
                  ),
                ),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No members found for this committee'.tr,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final group = filteredData[index];
                      return _buildRoleGroup(group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          itemHeight: 56,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
          style: const TextStyle(color: AppColors.secondary, fontSize: 13),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.replaceAll(':', ''), style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  Text(
                    val.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleGroup(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group Header
          InkWell(
            onTap: () {
              setState(() {
                group['isExpanded'] = !group['isExpanded'];
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${group['role']} (${group['count']})'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    group['isExpanded'] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          // Members List
          if (group['isExpanded'])
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (group['members'] as List).length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final member = group['members'][index];
                return _buildMemberTile(member, group['role']);
              },
            ),
        ],
      ),
    );
  }

  String _translateDate(String date) {
    List<String> parts = date.split(' ');
    if (parts.length == 2) {
      return '${parts[0].tr} ${parts[1]}';
    }
    return date.tr;
  }

  void _showMemberDetails(Map<String, dynamic> member, String role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Committee Member Details'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
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
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.person,
                                size: 50, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            (member['name'] as String).tr,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${role.tr} - ${(member['committee'] as String).tr}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Committee Details Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.assignment,
                                    size: 18, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'COMMITTEE DETAILS'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(),
                          ),
                          _buildDetailRow('Committee Name'.tr, (member['committee'] as String).tr),
                          _buildDetailRow('Role'.tr, role.tr),
                          _buildDetailRow('Start Date'.tr, '01 ${member['since']}'),
                          _buildDetailRow('End Date'.tr, '31 ${member['until']}'),
                          _buildDetailRow('Reports to'.tr,
                              (member['reportsTo'] as String?)?.tr ??
                                  'Amit Mehta (Treasurer)'.tr),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pushNamed(context, AppRouter.memberProfile);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'View Full Member Profile'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                fontSize: 13,
              ),
            ),
          ),
          const Text('  :   ',
              style: TextStyle(color: AppColors.mutedForeground)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, String role) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFFF1F5F9),
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: (member['name'] as String).tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: ' - ${(member['committee'] as String).tr}',
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          '${'Since:'.tr} ${_translateDate(member['since'])}  |  ${'Until:'.tr} ${_translateDate(member['until'])}',
          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
        ),
      ),
      trailing:
          const Icon(Icons.keyboard_arrow_right, color: AppColors.mutedForeground),
      onTap: () => _showMemberDetails(member, role),
    );
  }
}
