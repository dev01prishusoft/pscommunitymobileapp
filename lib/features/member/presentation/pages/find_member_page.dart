import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';

class FindMemberPage extends StatefulWidget {
  const FindMemberPage({super.key});

  @override
  State<FindMemberPage> createState() => _FindMemberPageState();
}

class _FindMemberPageState extends State<FindMemberPage> {
  final FindMemberController _controller = Get.find<FindMemberController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Find Member'.tr,
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
              onChanged: _controller.search,
              decoration: InputDecoration(
                hintText: 'Search by name or mobile or email...'.tr,
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedForeground),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mutedForeground),
                  onPressed: () {
                    _searchController.clear();
                    _controller.clearSearch();
                  },
                ),
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
                  'Showing '.tr,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 15),
                ),
                Text(
                  '${_controller.filteredMembers.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  ' members'.tr,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 15),
                ),
              ],
            ),
          )),

          // Member List
          Expanded(
            child: Obx(() => AppStateView(
              state: _controller.state.value,
              emptyMessage: 'No members found'.tr,
              onRetry: _controller.loadMembers,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _controller.filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _controller.filteredMembers[index];
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
                      leading: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFE2E8F0),
                        child: Icon(Icons.person, color: AppColors.mutedForeground, size: 30),
                      ),
                      title: Text(
                        member['name']!.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            member['info']!.tr,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                member['location']!.tr,
                                style: const TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward, color: AppColors.primary),
                      onTap: () => Get.toNamed(AppRouter.memberProfile),
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
