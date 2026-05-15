import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/relation_mapper.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';

class FamilyMembersListPage extends StatefulWidget {
  const FamilyMembersListPage({super.key});

  @override
  State<FamilyMembersListPage> createState() => _FamilyMembersListPageState();
}

class _FamilyMembersListPageState extends State<FamilyMembersListPage> {
  final FamilyController _controller = Get.find<FamilyController>();
  final TextEditingController _searchController = TextEditingController();
  int _areaId = 0;
  String _areaName = 'Daskroi (Satellite)';
  int _membersCount = 31;
  int _familiesCount = 15;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _areaId = (args['areaId'] as int?) ?? 0;
          _areaName = (args['areaName'] as String?) ?? _areaName;
          _membersCount = (args['membersCount'] as int?) ?? _membersCount;
          _familiesCount = (args['familiesCount'] as int?) ?? _familiesCount;
        });
      }
      _controller.loadFamilies(_areaId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Family> get _filteredFamilies {
    if (_searchQuery.isEmpty) return _controller.families;
    final query = _searchQuery.toLowerCase();
    return _controller.families.map((family) {
      final filteredMembers = family.members.where((member) {
        final name = member.name.toLowerCase();
        final mobile = member.mobileNo?.toLowerCase() ?? '';
        final id = member.id.toLowerCase();
        return name.contains(query) || mobile.contains(query) || id.contains(query);
      }).toList();
      if (filteredMembers.isEmpty) return null;
      return Family(familyName: family.familyName, members: filteredMembers);
    }).whereType<Family>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '$_membersCount ${LK.membersCount.tr}  |  $_familiesCount ${LK.familiesCount.tr}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                  hintText: LK.searchByMobileHint.tr,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
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

          Expanded(
            child: Obx(() => AppStateView(
              state: _controller.familyListState.value,
              onRetry: () => _controller.loadFamilies(_areaId),
              child: _filteredFamilies.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AppEmptyState(
                        icon: Icons.search_off,
                        secondaryIcon: Icons.search,
                        title: LK.noResultsFound.tr,
                        subtitle: LK.trySelectingDifferentFilters.tr,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _filteredFamilies.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final family = _filteredFamilies[index];
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
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  family.familyName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              ...family.members.asMap().entries.map((entry) {
                                return _MemberTile(
                                  member: entry.value,
                                  showDivider: entry.key > 0,
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            )),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.showDivider,
  });

  final FamilyMember member;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final avatarColors = _getAvatarColors(member.gender);
    
    return Column(
      children: [
        if (showDivider)
          const Divider(indent: 70, endIndent: 16),
        InkWell(
          onTap: () => Get.toNamed<void>(
            AppRouter.memberProfile,
            arguments: {'memberId': int.tryParse(member.id) ?? 0},
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColors.background,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '',
                    style: TextStyle(
                      color: avatarColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (member.isHead) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                LK.familyHead.tr,
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final genderKey = GenderMapper.getLabelKey(member.gender);
                          final relKey = RelationMapper.getLabelKey(member.relation);
                          final statusKey = MaritalStatusMapper.getLabelKey(member.maritalStatus);
                          
                          return Text(
                            '${genderKey != null ? genderKey.tr : member.gender}  •  ${relKey != null ? relKey.tr : member.relation}  •  ${statusKey != null ? statusKey.tr : member.maritalStatus}  •  ${member.occupation}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          );
                        }
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
  }

  ({Color background, Color text}) _getAvatarColors(String gender) {
    if (gender == 'Female') {
      return (background: const Color(0xFFFDE7F3), text: const Color(0xFFD61A87));
    }
    return (background: const Color(0xFFE2F1FB), text: const Color(0xFF1AA3E8));
  }
}
