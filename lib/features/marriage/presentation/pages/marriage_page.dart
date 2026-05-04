import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class MarriagePage extends StatefulWidget {
  const MarriagePage({super.key});

  @override
  State<MarriagePage> createState() => _MarriagePageState();
}

class _MarriagePageState extends State<MarriagePage> {
  bool _lookingForMarriage = true;
  String _selectedGender = 'All';
  bool _isAdvancedFiltersOpen = true;
  bool _excludeSameGotra = false;

  // Filter State Variables
  String _selectedAgeFrom = '18';
  String _selectedAgeTo = '60';
  String _selectedHeightFrom = '4.5 ft';
  String _selectedHeightTo = '6.5 ft';
  String _selectedGotra = 'Any';
  String _selectedMaritalStatus = 'All';
  String _selectedState = 'All';
  String _selectedDistrict = 'All';
  String _selectedTaluka = 'All';
  String _selectedEducation = 'Any';
  String _selectedOccupation = 'Any';
  String _selectedIncomeFrom = 'Any';
  String _selectedIncomeTo = 'Any';

  // Constants for Dropdowns
  final List<String> _ages = List.generate(43, (i) => (18 + i).toString());
  final List<String> _heights = List.generate(31, (i) => '${(4.0 + i * 0.1).toStringAsFixed(1)} ft');
  final List<String> _gotras = ['Any', 'Kashyap Gotra', 'Bharadwaj Gotra', 'Vashishtha Gotra'];
  final List<String> _maritalStatuses = ['All', 'Unmarried', 'Married', 'Widow', 'Widower', 'Divorced'];
  final List<String> _states = ['All', 'Gujarat', 'Maharashtra', 'Rajasthan'];
  final List<String> _districts = ['All', 'Ahmedabad', 'Gandhinagar', 'Vadodara', 'Surat'];
  final List<String> _talukas = ['All', 'Daskroi', 'City', 'Sector 21'];
  final List<String> _educations = ['Any', 'Secondary', 'Higher Secondary', 'Graduate', 'Post Graduate', 'PHD'];
  final List<String> _occupations = ['Any', 'Business', 'Engineer', 'Doctor', 'Teacher', 'Student', 'Homemaker'];
  final List<String> _incomeRanges = ['Any', '1-2 Lakh', '2-5 Lakh', '5-10 Lakh', '10+ Lakh'];

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Rajesh Patel',
      'age': '28 yrs',
      'occupation': 'Engineer',
      'gotra': 'Kashyap Gotra',
      'location': 'Ahmedabad, Daskroi, Satellite',
      'lookingForMarriage': true,
      'gender': 'Male',
      'avatarColor': Colors.blue.shade100,
      'avatarIconColor': Colors.blue,
    },
    {
      'name': 'Priya Shah',
      'age': '26 yrs',
      'occupation': 'Doctor',
      'gotra': 'Bharadwaj Gotra',
      'location': 'Ahmedabad, Daskroi, Naranpura',
      'lookingForMarriage': true,
      'gender': 'Female',
      'avatarColor': Colors.pink.shade100,
      'avatarIconColor': Colors.pink,
    },
    {
      'name': 'Amit Mehta',
      'age': '32 yrs',
      'occupation': 'Business',
      'gotra': 'Vashishtha Gotra',
      'location': 'Gandhinagar, City, Sector 21',
      'lookingForMarriage': false,
      'gender': 'Male',
      'avatarColor': Colors.blue.shade100,
      'avatarIconColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marriage'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildSummaryCard(
                        label: 'Unmarried Male'.tr,
                        count: '45',
                        icon: Icons.group,
                        iconColor: Colors.blue,
                        textColor: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        label: 'Unmarried Female'.tr,
                        count: '38',
                        icon: Icons.person,
                        iconColor: Colors.pink,
                        textColor: Colors.pink,
                      ),
                    ],
                  ),
                ),

                // Filters Row (Gender & Looking for)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Show :'.tr, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Looking for Marriage'.tr,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: _lookingForMarriage,
                                onChanged: (val) =>
                                    setState(() => _lookingForMarriage = val),
                                activeThumbColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Gender:'.tr, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isDense: true,
                                items: ['All', 'Male', 'Female']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.tr,
                                              style: const TextStyle(fontSize: 11)),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedGender = val!),
                              ),
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
                          decoration: InputDecoration(
                            hintText: 'Search by name or member ID...'.tr,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter Toggle Button
                      InkWell(
                        onTap: () => setState(() =>
                            _isAdvancedFiltersOpen = !_isAdvancedFiltersOpen),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isAdvancedFiltersOpen
                                ? AppColors.primary
                                : Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 20,
                            color: _isAdvancedFiltersOpen
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Member List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    return _buildMemberCard(_members[index]);
                  },
                ),
                const SizedBox(height: 80), // Space for bottom
              ],
            ),
          ),

          // Sliding Advanced Filters Panel
          if (_isAdvancedFiltersOpen)
            GestureDetector(
              onTap: () => setState(() => _isAdvancedFiltersOpen = false),
              child: Container(
                color: Colors.black26,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _isAdvancedFiltersOpen ? 0 : -MediaQuery.of(context).size.height,
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
                          'Advanced Filters'.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _isAdvancedFiltersOpen = false),
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
                            label: 'Age Range:'.tr,
                            fromValue: _selectedAgeFrom,
                            toValue: _selectedAgeTo,
                            items: _ages,
                            onFromChanged: (val) =>
                                setState(() => _selectedAgeFrom = val!),
                            onToChanged: (val) =>
                                setState(() => _selectedAgeTo = val!),
                          ),
                          const SizedBox(height: 12),
                          _buildFilterRow(
                            label: 'Height Range:'.tr,
                            fromValue: _selectedHeightFrom,
                            toValue: _selectedHeightTo,
                            items: _heights,
                            onFromChanged: (val) =>
                                setState(() => _selectedHeightFrom = val!),
                            onToChanged: (val) =>
                                setState(() => _selectedHeightTo = val!),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('Gotra:'.tr,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedGotra,
                                  items: _gotras,
                                  onChanged: (val) =>
                                      setState(() => _selectedGotra = val!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: _excludeSameGotra,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (val) =>
                                    setState(() => _excludeSameGotra = val!),
                              ),
                              Flexible(
                                child: Text('Exclude same gotra'.tr,
                                    style: const TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('Marital Status:'.tr,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedMaritalStatus,
                                  items: _maritalStatuses,
                                  onChanged: (val) => setState(
                                      () => _selectedMaritalStatus = val!),
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
                                  child: Text('Residence:'.tr,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('State:'.tr,
                                            style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: _buildDropdownField(
                                            value: _selectedState,
                                            items: _states,
                                            onChanged: (val) => setState(
                                                () => _selectedState = val!),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('District:'.tr,
                                            style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: _buildDropdownField(
                                            value: _selectedDistrict,
                                            items: _districts,
                                            onChanged: (val) => setState(
                                                () => _selectedDistrict = val!),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('Taluka:'.tr,
                                            style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: _buildDropdownField(
                                            value: _selectedTaluka,
                                            items: _talukas,
                                            onChanged: (val) => setState(
                                                () => _selectedTaluka = val!),
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
                                child: Text('Education:'.tr,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedEducation,
                                  items: _educations,
                                  onChanged: (val) =>
                                      setState(() => _selectedEducation = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('Occupation:'.tr,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedOccupation,
                                  items: _occupations,
                                  onChanged: (val) =>
                                      setState(() => _selectedOccupation = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFilterRow(
                            label: 'Income Range:'.tr,
                            fromValue: _selectedIncomeFrom,
                            toValue: _selectedIncomeTo,
                            items: _incomeRanges,
                            onFromChanged: (val) =>
                                setState(() => _selectedIncomeFrom = val!),
                            onToChanged: (val) =>
                                setState(() => _selectedIncomeTo = val!),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(
                                      () => _isAdvancedFiltersOpen = false),
                                  child: Text('Apply Filters'.tr),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: Text('Clear All'.tr),
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

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: member['avatarColor'],
              child: Icon(Icons.person, color: member['avatarIconColor'], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (member['name'] as String).tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(member['age'] as String).tr} | ${(member['occupation'] as String).tr} | ${(member['gotra'] as String).tr}',
                    style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (member['location'] as String).tr,
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Looking for Marriage:'.tr,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        member['lookingForMarriage'] ? 'Yes'.tr : 'No'.tr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: member['lookingForMarriage']
                                ? Colors.green
                                : Colors.red),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View'.tr, style: const TextStyle(fontSize: 12)),
                            
                          ],
                        ),
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

  Widget _buildFilterRow({
    required String label,
    required String fromValue,
    required String toValue,
    required List<String> items,
    required Function(String?) onFromChanged,
    required Function(String?) onToChanged,
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
        Text('to'.tr),
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
