import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/features/family/presentation/widgets/member_tile.dart';

class FamilyMembersListPage extends StatefulWidget {
  const FamilyMembersListPage({super.key});

  @override
  State<FamilyMembersListPage> createState() => _FamilyMembersListPageState();
}

class _FamilyMembersListPageState extends State<FamilyMembersListPage> {
  final FamilyController _controller = Get.find<FamilyController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late int _areaId;
  late String _areaName;
  late int _membersCount;
  late int _familiesCount;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _areaId = args['areaId'] as int? ?? 0;
    _areaName = args['areaName'] as String? ?? '';
    _membersCount = args['membersCount'] as int? ?? 0;
    _familiesCount = args['familiesCount'] as int? ?? 0;

    _controller.memberSearchQuery.value = '';
    _controller.loadFamilies(_areaId);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.loadFamilies(_areaId, isRefresh: false);
      }
    });
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _areaName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              '$_membersCount ${LK.membersCount.tr}  |  $_familiesCount ${LK.familiesCount.tr}',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: LK.searchByNameHint.tr,
                  hintStyle: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.mutedForeground,
                  ),
                  suffixIcon: Obx(
                    () => _controller.memberSearchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                            tooltip: LK.clearAll.tr,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _searchController.clear();
                              _controller.memberSearchQuery.value = '';
                            },
                          )
                        : SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  _controller.memberSearchQuery.value = value;
                },
              ),
            ),
          ),

          Expanded(
            child: Obx(
              () => AppStateView(
                state: _controller.familyListState.value,
                onRetry: () => _controller.loadFamilies(_areaId),
                child: _controller.filteredFamilies.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: AppEmptyState(
                                      icon: Icons.search_off,
                                      secondaryIcon: Icons.search,
                                      title: LK.noResultsFound.tr,
                                      subtitle:
                                          LK.trySelectingDifferentFilters.tr,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: _controller.filteredFamilies.length + (_controller.hasMoreFamilies.value ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          if (index == _controller.filteredFamilies.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final family = _controller.filteredFamilies[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    family.familyName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                Divider(height: 1.h),
                                ...family.members.asMap().entries.map((entry) {
                                  return MemberTile(
                                    member: entry.value,
                                    showDivider: entry.key > 0,
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
