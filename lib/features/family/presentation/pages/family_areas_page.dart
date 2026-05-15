import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';

class FamilyAreasPage extends StatefulWidget {
  const FamilyAreasPage({super.key});

  @override
  State<FamilyAreasPage> createState() => _FamilyAreasPageState();
}

class _FamilyAreasPageState extends State<FamilyAreasPage> {
  final controller = Get.find<FamilyController>();
  final ScrollController _scrollController = ScrollController();
 
   @override
   void initState() {
     super.initState();
     controller.resetFilters();
     controller.loadStates();
     _scrollController.addListener(_onScroll);
   }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadAreas(refresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.family.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterSection(),
              const SizedBox(height: 24),
              _ResultsHeader(),
              const SizedBox(height: 5),
              Obx(() => AppStateView(
                state: controller.state.value,
                onRetry: controller.loadAreas,
                child: controller.filteredAreas.isEmpty 
                    ? _EmptyState() 
                    : Column(
                        children: [
                          _AreasList(areas: controller.areas),
                          if (controller.isNextPageLoading.value)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.filtersExpanded.value = !controller.filtersExpanded.value,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    LK.locationFilters.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    controller.filtersExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: controller.filtersExpanded.value
                ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        _CustomDropdown(
                          hint: LK.selectState.tr,
                          value: controller.selectedState.value,
                            options: controller.states,
                            onChanged: controller.onStateChanged,
                            isLoading: controller.isStatesLoading.value,
                        ),
                        const SizedBox(height: 12),
                        _CustomDropdown(
                          hint: LK.selectDistrict.tr,
                          value: controller.selectedDistrict.value,
                            options: controller.districts,
                            onChanged: controller.onDistrictChanged,
                            isEnabled: controller.selectedState.value != null,
                            isLoading: controller.isDistrictsLoading.value,
                        ),
                        const SizedBox(height: 12),
                        _CustomDropdown(
                          hint: LK.selectTaluka.tr,
                          value: controller.selectedTaluka.value,
                            options: controller.talukas,
                            onChanged: controller.onTalukaChanged,
                            isEnabled:
                                controller.selectedDistrict.value != null,
                            isLoading: controller.isTalukasLoading.value,
                        ),
                        if (controller.selectedState.value != null ||
                            controller.selectedDistrict.value != null ||
                            controller.selectedTaluka.value != null) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.resetFilters,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(LK.reset.tr),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ));
  }
}

class _ResultsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();
    return Obx(() {
      if (controller.filteredAreas.isEmpty) return const SizedBox.shrink();
      return Text(
        LK.totalAreasLabel.trParams({
          'taluka': controller.selectedTaluka.value?.text ?? 'All',
          'count': controller.filteredAreas.length.toString(),
        }),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      );
    });
  }
}

class _AreasList extends StatelessWidget {

  const _AreasList({required this.areas});
  final List<FamilyArea> areas;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: areas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final area = areas[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Get.toNamed<void>(
                AppRouter.familyMembers,
                arguments: {
                  'areaId': area.id,
                  'areaName': '${area.location} (${area.title})',
                  'membersCount': area.members,
                  'familiesCount': area.families,
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${area.title} (${area.location})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${area.members} ${LK.membersCount.tr}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('|', style: TextStyle(color: AppColors.border)),
                            ),
                            Text(
                              '${area.families} ${LK.familiesCount.tr}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.map_outlined,
      secondaryIcon: Icons.location_on,
      title: LK.noAreasFound.tr,
      subtitle: LK.trySelectingDifferentFilters.tr,
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String hint;
  final DropdownItem? value;
  final List<DropdownItem> options;
  final void Function(DropdownItem?) onChanged;
  final bool isEnabled;
  final bool isLoading;

  const _CustomDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DropdownItem>(
            value: (value != null && options.any((o) => o.id == value!.id)) 
                ? options.firstWhere((o) => o.id == value!.id) 
                : null,
            hint: Text(
              hint,
              style: TextStyle(
                color: AppColors.mutedForeground.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            isExpanded: true,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.mutedForeground,
                  ),
            items: options.isEmpty 
              ? null 
              : options.map((option) {
                  return DropdownMenuItem<DropdownItem>(
                    value: option,
                    child: Text(
                      option.text,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: isEnabled ? onChanged : null,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 8,
            menuMaxHeight: 350,
          ),
        ),
      ),
    );
  }
}

