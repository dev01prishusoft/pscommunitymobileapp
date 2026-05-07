import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';

class OccupationProfilePage extends StatefulWidget {
  const OccupationProfilePage({super.key});

  @override
  State<OccupationProfilePage> createState() => _OccupationProfilePageState();
}

class _OccupationProfilePageState extends State<OccupationProfilePage> {
  final controller = Get.find<OccupationController>();
  int _occupationId = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('occupationId')) {
      _occupationId = args['occupationId'] as int;
      controller.loadOccupationDetails(_occupationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          'Occupation Profile'.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() => AppStateView(
            state: controller.detailsState.value,
            onRetry: () => controller.loadOccupationDetails(_occupationId),
            child: _buildProfileContent(),
          )),
    );
  }

  Widget _buildProfileContent() {
    final occ = controller.selectedOccupation.value;
    if (occ == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: occ.logoUrl != null && occ.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            occ.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.mutedForeground,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  (occ.memberName ?? 'N/A').tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${occ.name} at ${occ.companyName ?? 'N/A'}'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Occupation Details Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business_center,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'OCCUPATION'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),
                _buildDetailRow(Icons.person_outline, 'Occupation Type:'.tr,
                    (occ.occupationType ?? 'N/A').tr),
                _buildDetailRow(Icons.business_center_outlined,
                    'Occupation:'.tr, (occ.name).tr),
                _buildDetailRow(Icons.apartment, 'Company Name:'.tr,
                    (occ.companyName ?? 'N/A').tr),

                // Expandable Address Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: Text(
                          'Business Address:'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              (occ.businessAddress ?? 'N/A').tr,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (occ.businessAddress != null)
                              GestureDetector(
                                onTap: () {
                                  _showAddressPopup(occ.businessAddress!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Show more'.tr,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildDetailRow(Icons.phone_outlined, 'Mobile:'.tr,
                    (occ.mobile ?? 'N/A').tr),
                _buildDetailRow(Icons.description_outlined, 'Description:'.tr,
                    (occ.description ?? 'N/A').tr),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Button
          if (occ.memberId != null)
            ElevatedButton(
              onPressed: () {
                Get.toNamed<void>(
                  AppRouter.memberProfile,
                  arguments: {'memberId': occ.memberId},
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'View Full Member Profile'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddressPopup(String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('Full Address'.tr),
          ],
        ),
        content: Text(
          address.tr,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isLink ? AppColors.primary : AppColors.secondary,
                fontWeight: isLink ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          if (isLink) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
          ],
        ],
      ),
    );
  }
}
