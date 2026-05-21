import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';

class FindMemberPage extends StatefulWidget {
  const FindMemberPage({super.key});

  @override
  State<FindMemberPage> createState() => _FindMemberPageState();
}

class _FindMemberPageState extends State<FindMemberPage> {
  final FindMemberController _controller = Get.find<FindMemberController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.clearSearch();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreMembers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.findMember.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: LK.searchHint.tr,
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedForeground),
                suffixIcon: Obx(() {
                  if (_controller.isSearching.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    );
                  }
                  return _controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.mutedForeground),
                          onPressed: () {
                            _searchController.clear();
                            _controller.clearSearch();
                          },
                        )
                      : const SizedBox.shrink();
                }),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Member Count Section
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Text(
                  LK.showing.tr,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 15),
                ),
                Text(
                    ' ${_controller.members.length} ',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  LK.membersCount.tr,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 15),
                ),
              ],
            ),
          )),

          // Member List
          Expanded(
            child: Obx(() => AppStateView(
              state: _controller.state.value,
              emptyMessage: LK.noMembersFound.tr,
              onRetry: _controller.loadMembers,
              child: ListView.builder(
                  controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      _controller.members.length +
                      (_controller.hasMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                    if (index == _controller.members.length) {
                      return _buildLoader();
                    }

                    final member = _controller.members[index];
                    return _buildMemberCard(member);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return _FindMemberCard(member: member);
  }

  Widget _buildLoader() {
    return Obx(
      () => _controller.isLoadingMore.value
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : const SizedBox(height: 24),
    );
  }
}

class _FindMemberCard extends StatelessWidget {
  final Member member;

  const _FindMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final infoParts = <String>[];
    final genderKey = GenderMapper.getLabelKey(member.gender);
    if (genderKey != null) {
      infoParts.add(genderKey.tr);
    } else if (member.gender.isNotEmpty) {
      infoParts.add(member.gender);
    }
    
    if (member.age > 0) infoParts.add('${member.age} ${LK.ageYears.tr}');
    if (member.occupation.isNotEmpty) infoParts.add(member.occupation);
    final infoString = infoParts.join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: MemberAvatar(
          imageUrl: member.profilePhotoFullUrl,
          gender: member.gender,
          radius: 30,
        ),
        title: Text(
          member.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (infoString.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                infoString,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
            if (member.area.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      member.area,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: AppColors.primary),
        onTap: () => Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        ),
      ),
    );
  }
}
