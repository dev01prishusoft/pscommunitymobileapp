import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/added_members_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/widgets/added_member_card.dart';

class AddedMembersListPage extends StatefulWidget {
  const AddedMembersListPage({super.key});

  @override
  State<AddedMembersListPage> createState() => _AddedMembersListPageState();
}

class _AddedMembersListPageState extends State<AddedMembersListPage> {
  final AddedMembersController _controller = Get.put(AddedMembersController());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.fetchMembers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    Get.delete<AddedMembersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.addedMembers.tr)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildCountHeader(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.members.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (_controller.members.isEmpty && !_controller.isLoading.value) {
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: AppEmptyState(
                            icon: Icons.search_off,
                            secondaryIcon: Icons.search,
                            title: LK.noResultsFound.tr,
                            subtitle: LK.trySelectingDifferentFilters.tr,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _controller.members.length + (_controller.hasMore.value ? 1 : 0),
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == _controller.members.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final member = _controller.members[index];
                  return AddedMemberCard(member: member);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: LK.searchHint.tr,
            hintStyle: TextStyle(
              color: AppColors.grey,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.grey,
            ),
            suffixIcon: Obx(
              () => _controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _controller.onSearchChanged('');
                      },
                    )
                  : SizedBox.shrink(),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: _controller.onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildCountHeader() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.members.isEmpty) {
        return SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grey,
            ),
            children: [
              TextSpan(text: '${LK.showing.tr} '),
              TextSpan(
                text: '${_controller.totalCount.value}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' ${LK.membersCount.tr}'),
            ],
          ),
        ),
      );
    });
  }
}
