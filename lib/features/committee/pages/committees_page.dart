import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:pscommunitymobileapp/features/committee/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/core/models/committee_node.dart';
import 'package:pscommunitymobileapp/core/widgets/committee_card.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  final CommitteeController controller = Get.find<CommitteeController>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? CupertinoTextField(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                prefix: Icon(
                  Iconsax.search_normal_copy,
                  size: 15,
                ).paddingOnly(left: 10),
                suffix: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    controller.clearSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  },
                  child: Icon(
                    Iconsax.close_circle_copy,
                    size: 20,
                  ).paddingOnly(right: 10),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 1.w,
                  ),
                ),
                placeholder: LK.searchCommittees.tr,
                controller: _searchController,
                onChanged: controller.updateSearch,
              )
            : Text(LK.committees.tr),
        actions: [
          if (!_isSearchVisible)
            IconButton(
              icon: const Icon(Iconsax.search_normal_copy),
              onPressed: () {
                setState(() {
                  _isSearchVisible = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PaginatedListView<CommitteeNode, CommitteeController>(
              itemBuilder: (context, index, node) => CommitteeCard(node: node),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              padding: AppSpacing.pagePadding,
            ),
          ),
        ],
      ),
    );
  }
}
