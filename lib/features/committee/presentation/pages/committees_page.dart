import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/widgets/committee_card.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  final CommitteeController controller = Get.find<CommitteeController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.committees.tr)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppTextField(
                hint: LK.searchCommittees.tr,
                controller: _searchController,
                icon: Iconsax.search_normal_copy,
                onChanged: controller.updateSearch,
                suffixIcon: Obx(() {
                  return controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.grey),
                          onPressed: () {
                            _searchController.clear();
                            controller.clearSearch();
                          },
                        )
                      : const SizedBox.shrink();
                }),
              ),
            ),
          ),
          Expanded(
            child: PaginatedListView<CommitteeNode, CommitteeController>(
              itemBuilder: (context, index, node) => CommitteeCard(node: node),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
            ),
          ),
        ],
      ),
    );
  }
}
