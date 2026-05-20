import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';

class MarriagePage extends GetView<MarriageController> {
  const MarriagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.marriage.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Obx(() {
                      final maleCount = controller.unmarriedCounts
                          .firstWhereOrNull((e) => e.genderId == 1)
                          ?.count ?? 0;
                      final femaleCount = controller.unmarriedCounts
                          .firstWhereOrNull((e) => e.genderId == 6)
                          ?.count ?? 0;
                          
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  label: LK.unmarriedMale.tr,
                                  count: maleCount.toString(),
                                  icon: Icons.group,
                                  iconColor: Colors.blue,
                                  textColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSummaryCard(
                                  label: LK.unmarriedFemale.tr,
                                  count: femaleCount.toString(),
                                  icon: Icons.person,
                                  iconColor: Colors.pink,
                                  textColor: Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Filters Row (Gender & Looking for)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Text(LK.showLabel.tr, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    LK.lookingForMarriage.tr,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Obx(() => SizedBox(
                                  height: 24,
                                  width: 36,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: controller.lookingForMarriage.value,
                                      onChanged: (val) {
                                        controller.lookingForMarriage.value = val;
                                      },
                                      activeThumbColor: AppColors.primary,
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(LK.gender.tr, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedGender,
                                    staticItems: ['All', 'Male', 'Female'],
                                    mapper: (e) {
                                      if (e == 'All') return LK.all.tr;
                                      final key = GenderMapper.getLabelKey(e);
                                      return key != null ? key.tr : e;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.searchTextController,
                              onChanged: (val) {
                                controller.searchQuery.value = val;
                              },
                              decoration: InputDecoration(
                                hintText: LK.searchByFirstNameHint.tr,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    controller.searchTextController.clear();
                                    controller.searchQuery.value = '';
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Filter Toggle Button
                          Obx(() => InkWell(
                            onTap: () => controller.toggleAdvancedFilters(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: _dropdownDecoration().copyWith(
                                color: controller.isAdvancedFiltersOpen.value
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 20,
                                color: controller.isAdvancedFiltersOpen.value
                                    ? Colors.white
                                    : AppColors.secondary,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Member List using SliverList for performance
              Obx(() {
                if (controller.state.value == AppState.data) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMemberCard(controller.filteredMembers[index]);
                      },
                      childCount: controller.filteredMembers.length,
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateView(
                      state: controller.state.value,
                      emptyMessage: LK.noMatchesFound.tr,
                      child: const SizedBox.shrink(),
                    ),
                  );
                }
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for bottom
            ],
          ),

          // Sliding Advanced Filters Panel
          Obx(() => controller.isAdvancedFiltersOpen.value
            ? GestureDetector(
                onTap: () => controller.isAdvancedFiltersOpen.value = false,
                child: Container(
                  color: Colors.black26,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : const SizedBox.shrink()),
          
          Obx(() => AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: controller.isAdvancedFiltersOpen.value ? 0 : -MediaQuery.of(context).size.height * 1.5,
            left: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            LK.advancedFilters.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                controller.isAdvancedFiltersOpen.value = false,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterRow(
                              label: LK.ageRangeLabel.tr,
                              fromRx: controller.selectedAgeFrom,
                              toRx: controller.selectedAgeTo,
                              staticItems: controller.ages,
                            ),
                            const SizedBox(height: 12),
                            _buildFilterRow(
                              label: LK.heightRangeLabel.tr,
                              fromRx: controller.selectedHeightFrom,
                              toRx: controller.selectedHeightTo,
                              staticItems: controller.heights,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(LK.gotraLabel.tr,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedGotra,
                                    rxItems: controller.dynamicGotras,
                                    mapper: _translateFallback,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Obx(() => Checkbox(
                                  value: controller.excludeSameGotra.value,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (val) =>
                                      controller.excludeSameGotra.value = val!,
                                )),
                                Flexible(
                                  child: Text(LK.excludeSameGotra.tr,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(LK.maritalStatusLabel.tr,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedMaritalStatus,
                                    staticItems: controller.maritalStatuses,
                                    mapper: (val) {
                                      if (val == 'All') return LK.all.tr;
                                      final key = MaritalStatusMapper.getLabelKey(val);
                                      return key != null ? key.tr : val;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(LK.residenceLabel.tr,
                                        style: const TextStyle(fontSize: 13)),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(LK.stateLabel.tr,
                                              style: const TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildDropdownField(
                                              rxValue: controller.selectedState,
                                              rxItems: controller.states,
                                              prependAll: true,
                                              itemStringifier: (e) => (e as dynamic).text as String,
                                              mapper: _translateFallback,
                                              onChanged: (val) => controller.onStateChanged(val),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(LK.districtLabel.tr,
                                              style: const TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildDropdownField(
                                              rxValue: controller.selectedDistrict,
                                              rxItems: controller.districts,
                                              prependAll: true,
                                              itemStringifier: (e) => (e as dynamic).text as String,
                                              mapper: _translateFallback,
                                              onChanged: (val) => controller.onDistrictChanged(val),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(LK.talukaLabel.tr,
                                              style: const TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildDropdownField(
                                              rxValue: controller.selectedTaluka,
                                              rxItems: controller.talukas,
                                              prependAll: true,
                                              itemStringifier: (e) => (e as dynamic).text as String,
                                              mapper: _translateFallback,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(LK.areaLabel.tr,
                                              style: const TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildDropdownField(
                                              rxValue: controller.selectedArea,
                                              rxItems: controller.dynamicAreas,
                                              mapper: _translateFallback,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(LK.educationLabel.tr,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedEducation,
                                    rxItems: controller.dynamicEducations,
                                    mapper: _translateFallback,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(LK.occupationLabel.tr,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Expanded(
                                  child: _buildDropdownField(
                                    rxValue: controller.selectedOccupation,
                                    rxItems: controller.dynamicOccupations,
                                    mapper: _translateFallback,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildFilterRow(
                              label: LK.incomeRangeLabel.tr,
                              fromRx: controller.selectedIncomeFrom,
                              toRx: controller.selectedIncomeTo,
                              staticItems: controller.incomeRanges,
                              mapper: _translateFallback,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // applyFilters is automatic due to debouncer
                                      controller.isAdvancedFiltersOpen.value = false;
                                    },
                                    child: Text(LK.applyFilters.tr),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => controller.clearFilters(),
                                    child: Text(LK.clearAll.tr),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  String _translateFallback(String val) {
    if (val == 'All') return LK.all.tr;
    if (val == 'Any') return LK.any.tr;
    return val;
  }

  BoxDecoration _dropdownDecoration() => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
    borderRadius: BorderRadius.circular(8),
  );

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11, 
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    final avatarColors = _getAvatarColors(member.gender);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            member.profilePhotoFullUrl != null && member.profilePhotoFullUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: member.profilePhotoFullUrl!,
                    imageBuilder: (context, ImageProvider imageProvider) => CircleAvatar(
                      radius: 30,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => CircleAvatar(
                      radius: 30,
                      backgroundColor: avatarColors.background,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 30,
                      backgroundColor: avatarColors.background,
                      child: Icon(Icons.person, color: avatarColors.icon, size: 30),
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: avatarColors.background,
                    child: Icon(Icons.person, color: avatarColors.icon, size: 30),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.age} ${LK.ageYears.tr} | ${member.occupation} | ${member.gotra}',
                    style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 4),
                  if (member.area.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            member.area,
                            style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(LK.lookingForMarriage.tr,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        (member.isLookingforMarriage == true) ? LK.yes.tr : LK.no.tr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: (member.isLookingforMarriage == true)
                                ? Colors.green
                                : Colors.red),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Get.toNamed<void>(
                          AppRouter.memberProfile,
                          arguments: {'memberId': member.memberId},
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: Text(LK.view.tr, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color background, Color icon}) _getAvatarColors(String gender) {
    if (gender == 'Female') {
      return (background: const Color(0xFFFCE4EC), icon: Colors.pink);
    }
    return (background: const Color(0xFFE3F2FD), icon: Colors.blue);
  }

  Widget _buildFilterRow({
    required String label,
    required RxString fromRx,
    required RxString toRx,
    List<String>? staticItems,
    String Function(String)? mapper,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: _buildDropdownField(
            rxValue: fromRx,
            staticItems: staticItems,
            mapper: mapper,
          ),
        ),
        const SizedBox(width: 8),
        Text(LK.to.tr),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdownField(
            rxValue: toRx,
            staticItems: staticItems,
            mapper: mapper,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required RxString rxValue,
    List<String>? staticItems,
    RxList<dynamic>? rxItems,
    String Function(dynamic)? itemStringifier,
    bool prependAll = false,
    bool prependAny = false,
    void Function(String)? onChanged,
    String Function(String)? mapper,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: _dropdownDecoration(),
      child: DropdownButtonHideUnderline(
        child: Obx(() {
          final val = rxValue.value;
          List<String> items = [];
          if (staticItems != null) {
            items = List.from(staticItems);
          } else if (rxItems != null) {
            if (prependAll) items.add('All');
            if (prependAny) items.add('Any');
            items.addAll(rxItems.map((e) => itemStringifier != null ? itemStringifier(e) : e.toString()));
          }
          
          if (!items.contains(val) && items.isNotEmpty) {
            items.add(val);
          }
          
          return DropdownButton<String>(
            value: val,
            isDense: true,
            isExpanded: true,
            focusColor: Colors.transparent,
            style: const TextStyle(fontSize: 12, color: AppColors.foreground),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            items: items.toSet().toList().map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  mapper != null ? mapper(e) : e,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newVal) {
              if (newVal != null) {
                rxValue.value = newVal;
                onChanged?.call(newVal);
              }
            },
          );
        }),
      ),
    );
  }
}
