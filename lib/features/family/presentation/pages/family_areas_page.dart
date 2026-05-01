import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class FamilyAreasPage extends StatefulWidget {
  const FamilyAreasPage({super.key});

  @override
  State<FamilyAreasPage> createState() => _FamilyAreasPageState();
}

class _FamilyAreasPageState extends State<FamilyAreasPage> {
  bool _filtersExpanded = true;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;

  // Mock data
  final List<Map<String, dynamic>> _areas = [
    {
      'title': 'Residential Area',
      'location': 'Daskroi',
      'members': 23,
      'families': 12,
    },
    {
      'title': 'Commercial Area',
      'location': 'Daskroi',
      'members': 8,
      'families': 3,
    },
    {
      'title': 'Industrial Area',
      'location': 'Daskroi',
      'members': 15,
      'families': 7,
    },
  ];

  List<Map<String, dynamic>> get _filteredAreas {
    // If any filter is selected, return an empty list to demonstrate the empty state
    // In a real app, this would filter based on actual matching data.
    if (_selectedState != null || _selectedDistrict != null || _selectedTaluka != null) {
      return [];
    }
    return _areas;
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Family - Areas'.tr,
          style: const TextStyle(
            color: Color(0xFF1E293B),
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
              _buildFilterSection(),
              const SizedBox(height: 24),
              _buildResultsHeader(),
              const SizedBox(height: 5),
              if (_filteredAreas.isEmpty) _buildEmptyState() else _buildAreasList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1.5),
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
            onTap: () {
              setState(() {
                _filtersExpanded = !_filtersExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Color(0xFF0096FF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Location Filters'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _filtersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _filtersExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      children: [
                        const Divider(height: 1, thickness: 0.7, color: Color.fromARGB(255, 204, 205, 206)),
                        const SizedBox(height: 16),
                        CustomExpandableDropdown(
                          hint: 'Select State'.tr,
                          value: _selectedState,
                          options: const ['Option 1', 'Option 2', 'Option 3'],
                          onChanged: (val) {
                            setState(() => _selectedState = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomExpandableDropdown(
                          hint: 'Select District'.tr,
                          value: _selectedDistrict,
                          options: const ['Option 1', 'Option 2', 'Option 3'],
                          onChanged: (val) {
                            setState(() => _selectedDistrict = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomExpandableDropdown(
                          hint: 'Select Taluka'.tr,
                          value: _selectedTaluka,
                          options: const ['Option 1', 'Option 2', 'Option 3'],
                          onChanged: (val) {
                            setState(() => _selectedTaluka = val);
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],

      ),
    );
  }



  Widget _buildResultsHeader() {
    if (_filteredAreas.isEmpty) return const SizedBox.shrink();

    return Text(
      'Total Areas in Daskroi Taluka: 8'.tr,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildAreasList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredAreas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final area = _filteredAreas[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.toNamed(
                  AppRouter.familyMembers,
                  arguments: {
                    'areaName': '${area['location'].toString().tr} (${area['title'].toString().tr})',
                    'membersCount': area['members'],
                    'familiesCount': area['families'],
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
                            '${area['title'].toString().tr} (${area['location'].toString().tr})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${area['members']} ${'Members'.tr}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('|', style: TextStyle(color: Color(0xFFCBD5E1))),
                              ),
                              Text(
                                '${area['families']} ${'Families'.tr}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0096FF),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255,245, 248, 254), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(150, 217, 220, 223), width: 1.5),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.map_outlined, size: 80, color: const Color(0xFF0096FF).withValues(alpha: 0.15)),
              const Positioned(
                top: 10,
                child: Icon(Icons.location_on, size: 40, color: Color(0xFF0096FF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No Areas Found'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting different filters'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomExpandableDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> options;
  final Function(String?) onChanged;

  const CustomExpandableDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<CustomExpandableDropdown> createState() => _CustomExpandableDropdownState();
}

class _CustomExpandableDropdownState extends State<CustomExpandableDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value != null ? widget.value!.tr : widget.hint,
                      style: TextStyle(
                        color: widget.value != null ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: widget.value != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFf5f8fe)),
                      ),
                    ),
                    child: Column(
                      children: widget.options.isEmpty
                          ? [
                              Container(
                                width: double.infinity,
                                color: const Color(0xFFF8FAFC),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                child: Text(
                                  'No data found'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            ]
                          : widget.options.map((option) {
                              final isSelected = option == widget.value;
                              return InkWell(
                                onTap: () {
                                  widget.onChanged(option);
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  color: isSelected ? const Color(0xFFF0F7FF) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option.tr,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFF0096FF) : const Color(0xFF475569),
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check, color: Color(0xFF0096FF), size: 18),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

