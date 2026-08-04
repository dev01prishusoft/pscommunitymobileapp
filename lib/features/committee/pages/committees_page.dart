import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';

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
            ? CupertinoSearchbar(
              onTapSuffix: () {
                    _searchController.clear();
                    controller.clearSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  },
                hintText: LK.searchCommittees.tr,
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchController.clear();
                    controller.clearSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  } else {
                    controller.updateSearch(value);
                  }
                },
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
