import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

class OccupationDirectoryPage extends StatefulWidget {
  const OccupationDirectoryPage({super.key});

  @override
  State<OccupationDirectoryPage> createState() => _OccupationDirectoryPageState();
}

class _OccupationDirectoryPageState extends State<OccupationDirectoryPage> {
  final OccupationController _controller = Get.find<OccupationController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadOccupations(occupationTypeId: 6);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Occupation Directory'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _controller.search,
              decoration: InputDecoration(
                hintText: 'Search occupation...'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _controller.clearSearch();
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Occupation Dropdown (Static for now as per original UI)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('${'Occupation:'.tr} ',
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  Text('All'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid View
          Expanded(
            child: Obx(() => AppStateView(
              state: _controller.state.value,
              onRetry: _controller.loadOccupations,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _controller.filteredOccupations.length,
                  itemBuilder: (context, index) {
                    final occ = _controller.filteredOccupations[index];
                    return _buildOccupationCard(occ);
                  },
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationCard(OccupationItem occ) {
    return InkWell(
      onTap: () => Get.toNamed(
        AppRouter.occupationProfile,
        arguments: {'occupationId': occ.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            occ.logoUrl != null && occ.logoUrl!.isNotEmpty
                ? Image.network(
                    occ.logoUrl!,
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getIconData(occ.iconKey),
                      size: 40,
                      color: AppColors.primary,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  )
                : Icon(
                    _getIconData(occ.iconKey),
                    size: 40,
                    color: AppColors.primary,
                  ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                occ.name.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String? key) {
    if (key == null) return Icons.work_rounded;
    switch (key) {
      case 'computer':
        return Icons.computer_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      default:
        return Icons.work_rounded;
    }
  }
}
