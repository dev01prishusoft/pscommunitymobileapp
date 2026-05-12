import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OccupationDirectoryPage extends StatefulWidget {
  const OccupationDirectoryPage({super.key});

  @override
  State<OccupationDirectoryPage> createState() => _OccupationDirectoryPageState();
}

class _OccupationDirectoryPageState extends State<OccupationDirectoryPage> {
  final OccupationController _controller = Get.find<OccupationController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _controller.loadOccupations(refresh: false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          LK.occupationDirectoryLabel.tr,
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
                hintText: LK.searchOccupation.tr,
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

          // Occupation Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _controller.selectedOccupationType.value?.id ?? 0,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  items: _controller.occupationTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type.id,
                      child: Row(
                        children: [
                          Text(LK.occupationColon.tr,
                              style: const TextStyle(color: AppColors.mutedForeground)),
                          const SizedBox(width: 4),
                          Text(type.text.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final type = _controller.occupationTypes.firstWhere((t) => t.id == id);
                    _controller.onOccupationTypeChanged(id == 0 ? null : type);
                  },
                ),
              )),
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
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
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
                    if (_controller.isNextPageLoading.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
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
      onTap: () => Get.toNamed<void>(
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
                ? CachedNetworkImage(
                    imageUrl: occ.logoUrl!,
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      _getIconData(occ.iconKey),
                      size: 40,
                      color: AppColors.primary,
                    ),
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
                occ.name,
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
