import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';

class FamilyAreasPage extends StatefulWidget {
  const FamilyAreasPage({super.key});

  @override
  State<FamilyAreasPage> createState() => _FamilyAreasPageState();
}

class _FamilyAreasPageState extends State<FamilyAreasPage> {
  final controller = Get.find<FamilyController>();

  @override
  void initState() {
    super.initState();
    controller.loadStates();
    controller.loadAreas();
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Family - Areas'.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                    : _AreasList(areas: controller.filteredAreas),
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
                    'Location Filters'.tr,
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
                          hint: 'Select State'.tr,
                          value: controller.selectedState.value,
                            options: controller.states,
                            onChanged: controller.onStateChanged,
                            isLoading: controller.isStatesLoading.value,
                        ),
                        const SizedBox(height: 12),
                        _CustomDropdown(
                          hint: 'Select District'.tr,
                          value: controller.selectedDistrict.value,
                            options: controller.districts,
                            onChanged: controller.onDistrictChanged,
                            isEnabled: controller.selectedState.value != null,
                            isLoading: controller.isDistrictsLoading.value,
                        ),
                        const SizedBox(height: 12),
                        _CustomDropdown(
                          hint: 'Select Taluka'.tr,
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
        'Total Areas in Daskroi Taluka: 8'.tr, // In real app, make dynamic
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
              Get.toNamed(
                AppRouter.familyMembers,
                arguments: {
                  'areaId': area.id,
                  'areaName': '${area.location.tr} (${area.title.tr})',
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
                          '${area.title.tr} (${area.location.tr})',
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
                              '${area.members} ${'Members'.tr}',
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
                              '${area.families} ${'Families'.tr}',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.map_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.15)),
              const Positioned(
                top: 10,
                child: Icon(Icons.location_on, size: 40, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No Areas Found'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting different filters'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDropdown extends StatefulWidget {
  final String hint;
  final DropdownItem? value;
  final List<DropdownItem> options;
  final Function(DropdownItem?) onChanged;
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
  State<_CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<_CustomDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final opacity = widget.isEnabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.isEnabled
                  ? () => setState(() => _isExpanded = !_isExpanded)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.value != null ? widget.value!.text : widget.hint,
                        style: TextStyle(
                          color: widget.value != null
                              ? AppColors.secondary
                              : AppColors.mutedForeground,
                          fontSize: 14,
                          fontWeight: widget.value != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    widget.isLoading
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
                        : Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.mutedForeground,
                          ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isExpanded && widget.isEnabled
                  ? widget.options.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Text(
                              'No items found'.tr,
                              style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Column(
                            children: widget.options.map((option) {
                              final isSelected = option == widget.value;
                              return InkWell(
                                onTap: () {
                                  widget.onChanged(option);
                                  setState(() => _isExpanded = false);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  color: isSelected
                                      ? const Color(0xFFF0F7FF)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option.text,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.secondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
