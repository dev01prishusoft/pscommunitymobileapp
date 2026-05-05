import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class OccupationDirectoryPage extends StatefulWidget {
  const OccupationDirectoryPage({super.key});

  @override
  State<OccupationDirectoryPage> createState() => _OccupationDirectoryPageState();
}

class _OccupationDirectoryPageState extends State<OccupationDirectoryPage> {
  final List<Map<String, dynamic>> _occupations = [
    {'name': 'Engineer', 'count': 24, 'icon': Icons.engineering},
    {'name': 'Doctor', 'count': 12, 'icon': Icons.local_hospital},
    {'name': 'Teacher', 'count': 10, 'icon': Icons.school},
    {'name': 'Trader', 'count': 8, 'icon': Icons.business_center},
    {'name': 'Lawyer', 'count': 6, 'icon': Icons.gavel},
    {'name': 'Business Owner', 'count': 5, 'icon': Icons.factory},
    {'name': 'Accountant', 'count': 4, 'icon': Icons.analytics},
    {'name': 'Architect', 'count': 3, 'icon': Icons.account_balance},
    {'name': 'Software Dev', 'count': 7, 'icon': Icons.code},
  ];

  final String _selectedOccupation = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        title: Text(
          'Occupation Directory'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search occupation...'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.close),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Occupation Dropdown
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
                  Text(_selectedOccupation.tr,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _occupations.length,
                itemBuilder: (context, index) {
                  final occ = _occupations[index];
                  return _buildOccupationCard(occ);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationCard(Map<String, dynamic> occ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.occupationProfile);
      },
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
          Icon(
            occ['icon'] as IconData,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              (occ['name'] as String).tr,
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
          const SizedBox(height: 4),
          Text(
            '${occ['count']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
