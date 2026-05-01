import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class FamilyMembersListPage extends StatefulWidget {
  const FamilyMembersListPage({super.key});

  @override
  State<FamilyMembersListPage> createState() => _FamilyMembersListPageState();
}

class _FamilyMembersListPageState extends State<FamilyMembersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _areaName = 'Daskroi (Satellite)';
  int _membersCount = 31;
  int _familiesCount = 15;
  String _searchQuery = '';
  
  // Mock families data matching the image
  final List<Map<String, dynamic>> _families = [
    {
      'familyName': 'Patel Family',
      'members': [
        {
          'id': 'RK',
          'name': 'Rajesh Kumar Patel',
          'isHead': true,
          'gender': 'Male',
          'relation': 'Self',
          'maritalStatus': 'Married',
          'occupation': 'Engineer',
          'color': const Color(0xFFE2F1FB),
          'textColor': const Color(0xFF1AA3E8),
        },
        {
          'id': 'PP',
          'name': 'Priya Patel',
          'isHead': false,
          'gender': 'Female',
          'relation': 'Wife',
          'maritalStatus': 'Married',
          'occupation': 'Teacher',
          'color': const Color(0xFFFDE7F3),
          'textColor': const Color(0xFFD61A87),
        },
        {
          'id': 'KP',
          'name': 'Krish Patel',
          'isHead': false,
          'gender': 'Male',
          'relation': 'Son',
          'maritalStatus': 'Unmarried',
          'occupation': 'Student',
          'color': const Color(0xFFE2F1FB),
          'textColor': const Color(0xFF1AA3E8),
        },
      ],
    },
    {
      'familyName': 'Mehta Family',
      'members': [
        {
          'id': 'AM',
          'name': 'Amit Mehta',
          'isHead': true,
          'gender': 'Male',
          'relation': 'Self',
          'maritalStatus': 'Married',
          'occupation': 'Business',
          'color': const Color(0xFFE2F1FB),
          'textColor': const Color(0xFF1AA3E8),
        },
        {
          'id': 'NM',
          'name': 'Neha Mehta',
          'isHead': false,
          'gender': 'Female',
          'relation': 'Wife',
          'maritalStatus': 'Married',
          'occupation': 'Doctor',
          'color': const Color(0xFFFDE7F3),
          'textColor': const Color(0xFFD61A87),
        },
      ],
    },
    {
      'familyName': 'Shah Family',
      'members': [
        {
          'id': 'KS',
          'name': 'Kiran Shah',
          'isHead': true,
          'gender': 'Female',
          'relation': 'Self',
          'maritalStatus': 'Widow',
          'occupation': 'Teacher',
          'color': const Color(0xFFFDE7F3),
          'textColor': const Color(0xFFD61A87),
        },
        {
          'id': 'RS',
          'name': 'Riya Shah',
          'isHead': false,
          'gender': 'Female',
          'relation': 'Daughter',
          'maritalStatus': 'Unmarried',
          'occupation': 'Student',
          'color': const Color(0xFFFDE7F3),
          'textColor': const Color(0xFFD61A87),
        },
      ],
    },
    {
      'familyName': 'Joshi Family',
      'members': [
        {
          'id': 'MJ',
          'name': 'Manoj Joshi',
          'isHead': true,
          'gender': 'Male',
          'relation': 'Self',
          'maritalStatus': 'Married',
          'occupation': 'Accountant',
          'color': const Color(0xFFE2F1FB),
          'textColor': const Color(0xFF1AA3E8),
        },
        {
          'id': 'PJ',
          'name': 'Pooja Joshi',
          'isHead': false,
          'gender': 'Female',
          'relation': 'Wife',
          'maritalStatus': 'Married',
          'occupation': 'Homemaker',
          'color': const Color(0xFFFDE7F3),
          'textColor': const Color(0xFFD61A87),
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Read navigation arguments once, safely in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _areaName = args['areaName'] ?? _areaName;
          _membersCount = args['membersCount'] ?? _membersCount;
          _familiesCount = args['familiesCount'] ?? _familiesCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered list based on search query
  List<Map<String, dynamic>> get _filteredFamilies {
    if (_searchQuery.isEmpty) return _families;
    final query = _searchQuery.toLowerCase();
    return _families.map((family) {
      final filteredMembers = (family['members'] as List<dynamic>).where((member) {
        final name = member['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
      if (filteredMembers.isEmpty) return null;
      return {'familyName': family['familyName'], 'members': filteredMembers};
    }).whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _areaName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$_membersCount ${'Members'.tr}  |  $_familiesCount ${'Families'.tr}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or mobile...'.tr,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // List of Families
          Expanded(
            child: _filteredFamilies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No results found'.tr,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _filteredFamilies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final family = _filteredFamilies[index];
                final members = family['members'] as List<dynamic>;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0, right: 16.0),
                        child: Text(
                          family['familyName'].toString().tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ...members.asMap().entries.map((entry) {
                        final memberIndex = entry.key;
                        final member = entry.value;
                        return Column(
                          children: [
                            if (memberIndex > 0)
                              const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 70, endIndent: 16),
                            InkWell(
                              onTap: () {
                                // Tap handler (e.g. view details)
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: member['color'],
                                      child: Text(
                                        member['id'],
                                        style: TextStyle(
                                          color: member['textColor'],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Member Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  member['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (member['isHead']) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFDCFCE7),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'Family Head'.tr,
                                                    style: const TextStyle(
                                                      color: Color(0xFF16A34A),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${member['gender'].toString().tr}  •  ${member['relation'].toString().tr}  •  ${member['maritalStatus'].toString().tr}  •  ${member['occupation'].toString().tr}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
