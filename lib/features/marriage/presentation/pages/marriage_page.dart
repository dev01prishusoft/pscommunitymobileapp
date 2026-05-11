import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarriagePage extends StatefulWidget {
  const MarriagePage({super.key});

  @override
  State<MarriagePage> createState() => _MarriagePageState();
}

class _MarriagePageState extends State<MarriagePage> {
  final MarriageController _controller = Get.find<MarriageController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadProfiles();
  }

  // Constants for Dropdowns (kept here for UI list)
  final List<String> _ages = List.generate(43, (i) => (18 + i).toString());
  final List<String> _heights = List.generate(31, (i) => '${(4.0 + i * 0.1).toStringAsFixed(1)} ft');
  final List<String> _gotras = ['Any', 'Kashyap Gotra', 'Bharadwaj Gotra', 'Vashishtha Gotra'];
  final List<String> _maritalStatuses = ['All', 'Unmarried', 'Married', 'Widow', 'Widower', 'Divorced'];
  final List<String> _states = ['All', 'Gujarat', 'Maharashtra', 'Rajasthan'];
  final List<String> _districts = ['All', 'Ahmedabad', 'Gandhinagar', 'Vadodara', 'Surat'];
  final List<String> _talukas = ['All', 'Daskroi', 'City', 'Sector 21'];
  final List<String> _areas = ['All', 'Satellite', 'Bopal', 'Prahladnagar'];
  final List<String> _educations = ['Any', 'Secondary', 'Higher Secondary', 'Graduate', 'Post Graduate', 'PHD'];
  final List<String> _occupations = ['Any', 'Business', 'Engineer', 'Doctor', 'Teacher', 'Student', 'Homemaker'];
  final List<String> _incomeRanges = ['Any', '1-2 Lakh', '2-5 Lakh', '5-10 Lakh', '10+ Lakh'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.marriageLabel.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Obx(() {
                  final maleCount = _controller.unmarriedCounts
                      .firstWhereOrNull((e) => e.genderId == 1)
                      ?.count ?? 0;
                  final femaleCount = _controller.unmarriedCounts
                      .firstWhereOrNull((e) => e.genderId == 6)
                      ?.count ?? 0;
                      
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
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
                        const SizedBox(width: 16),
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
                  );
                }),

                // Filters Row (Gender & Looking for)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(LK.showLabel.tr, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                LK.lookingForMarriage.tr,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Obx(() => Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: _controller.lookingForMarriage.value,
                                onChanged: (val) {
                                  _controller.lookingForMarriage.value = val;
                                },
                                activeThumbColor: AppColors.primary,
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(LK.gender.tr, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: Obx(() => DropdownButton<String>(
                                value: _controller.selectedGender.value,
                                isDense: true,
                                items: ['All', 'Male', 'Female']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.tr,
                                              style: const TextStyle(fontSize: 11)),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  _controller.selectedGender.value = val!;
                                },
                              )),
                            ),
                          ),
                        ],
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
                          controller: _searchController,
                          onChanged: (val) {
                            _controller.searchQuery.value = val;
                          },
                          decoration: InputDecoration(
                            hintText: LK.searchMemberHint.tr,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                _controller.searchQuery.value = '';
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
                        onTap: () => _controller.toggleAdvancedFilters(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _controller.isAdvancedFiltersOpen.value
                                ? AppColors.primary
                                : Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 20,
                            color: _controller.isAdvancedFiltersOpen.value
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),

                // Member List
                Obx(() => AppStateView(
                  state: _controller.state.value,
                  emptyMessage: LK.noMatchesFound.tr,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.filteredMembers.length,
                    itemBuilder: (context, index) {
                      return _buildMemberCard(_controller.filteredMembers[index]);
                    },
                  ),
                )),
                const SizedBox(height: 80), // Space for bottom
              ],
            ),
          ),

          // Sliding Advanced Filters Panel
          Obx(() => _controller.isAdvancedFiltersOpen.value
            ? GestureDetector(
                onTap: () => _controller.isAdvancedFiltersOpen.value = false,
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
            top: _controller.isAdvancedFiltersOpen.value ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                              _controller.isAdvancedFiltersOpen.value = false,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterRow(
                            label: LK.ageRangeLabel.tr,
                            fromValue: _controller.selectedAgeFrom.value,
                            toValue: _controller.selectedAgeTo.value,
                            items: _ages,
                            onFromChanged: (val) =>
                                _controller.selectedAgeFrom.value = val!,
                            onToChanged: (val) =>
                                _controller.selectedAgeTo.value = val!,
                          ),
                          const SizedBox(height: 12),
                          _buildFilterRow(
                            label: LK.heightRangeLabel.tr,
                            fromValue: _controller.selectedHeightFrom.value,
                            toValue: _controller.selectedHeightTo.value,
                            items: _heights,
                            onFromChanged: (val) =>
                                _controller.selectedHeightFrom.value = val!,
                            onToChanged: (val) =>
                                _controller.selectedHeightTo.value = val!,
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
                                  value: _controller.selectedGotra.value,
                                  items: _gotras,
                                  onChanged: (val) =>
                                      _controller.selectedGotra.value = val!,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: _controller.excludeSameGotra.value,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (val) =>
                                    _controller.excludeSameGotra.value = val!,
                              ),
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
                                  value: _controller.selectedMaritalStatus.value,
                                  items: _maritalStatuses,
                                  onChanged: (val) => _controller.selectedMaritalStatus.value = val!,
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
                                            value: _controller.selectedState.value,
                                            items: _states,
                                            onChanged: (val) => _controller.selectedState.value = val!,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(LK.districtLabel.tr,
                                            style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: _buildDropdownField(
                                            value: _controller.selectedDistrict.value,
                                            items: _districts,
                                            onChanged: (val) => _controller.selectedDistrict.value = val!,
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
                                            value: _controller.selectedTaluka.value,
                                            items: _talukas,
                                            onChanged: (val) => _controller.selectedTaluka.value = val!,
                                          ),
                                        ),
                                          const SizedBox(width: 8),
                                          Text(
                                            LK.areaLabel.tr,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildDropdownField(
                                              value: _controller
                                                  .selectedArea
                                                  .value,
                                              items: _areas,
                                              onChanged: (val) =>
                                                  _controller
                                                          .selectedArea
                                                          .value =
                                                      val!,
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
                                  value: _controller.selectedEducation.value,
                                  items: _educations,
                                  onChanged: (val) =>
                                      _controller.selectedEducation.value = val!,
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
                                  value: _controller.selectedOccupation.value,
                                  items: _occupations,
                                  onChanged: (val) =>
                                      _controller.selectedOccupation.value = val!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFilterRow(
                            label: LK.incomeRangeLabel.tr,
                            fromValue: _controller.selectedIncomeFrom.value,
                            toValue: _controller.selectedIncomeTo.value,
                            items: _incomeRanges,
                            onFromChanged: (val) =>
                                _controller.selectedIncomeFrom.value = val!,
                            onToChanged: (val) =>
                                _controller.selectedIncomeTo.value = val!,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _controller.applyFilters();
                                    _controller.isAdvancedFiltersOpen.value = false;
                                  },
                                  child: Text(LK.applyFilters.tr),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _controller.clearFilters(),
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
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              Text(count,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            ],
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
                    member.name.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.age} ${LK.ageYears.tr} | ${member.occupation.tr} | ${member.gotra.tr}',
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
                        (member.isLookingforMarriage ?? false) ? LK.yes.tr : LK.no.tr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: (member.isLookingforMarriage ?? false)
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
    required String fromValue,
    required String toValue,
    required List<String> items,
    required void Function(String?) onFromChanged,
    required void Function(String?) onToChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: _buildDropdownField(
            value: fromValue,
            items: items,
            onChanged: onFromChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text(LK.to.tr),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdownField(
            value: toValue,
            items: items,
            onChanged: onToChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: AppColors.foreground),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.tr),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
