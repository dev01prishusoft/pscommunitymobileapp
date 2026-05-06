import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberProfilePage extends StatelessWidget {
  const MemberProfilePage({super.key});

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (urlString.startsWith('tel:')) {
        final String number = urlString.replaceFirst('tel:', '');
        final Uri telUri = Uri(scheme: 'tel', path: number);
        await launchUrl(telUri);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Member Details'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.muted,
                      child: Icon(Icons.person,
                          size: 50, color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rajesh Kumar Patel'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Head of Family'.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSection(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 52,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final items = [
                    _buildGridItem(
                      Icons.person_outline,
                      'Gender (Relationship)'.tr,
                      'Male (Self)'.tr,
                    ),
                    _buildGridItem(
                      Icons.water_drop_outlined,
                      'Blood Group'.tr,
                      'O+',
                    ),
                    _buildGridItem(
                      Icons.calendar_today_outlined,
                      'Birth Date (Age)'.tr,
                      '15 Mar 1992 (32 yrs)'.tr,
                    ),
                    _buildGridItem(Icons.height, 'Height'.tr, '5 ft 9 in'),
                    _buildGridItem(
                      Icons.access_time,
                      'Birth Time'.tr,
                      '08:45 AM',
                    ),
                    _buildGridItem(
                      Icons.monitor_weight_outlined,
                      'Weight'.tr,
                      '72 kg',
                    ),
                    _buildGridItem(
                      Icons.star_outline,
                      'Zodiac Sign'.tr,
                      'Aries'.tr,
                    ),
                    _buildGridItem(
                      Icons.person_outline,
                      "Father's Name".tr,
                      'Shri Amritlal Patel'.tr,
                    ),
                    _buildGridItem(
                      Icons.work_outline,
                      'Occupation'.tr,
                      'Engineer'.tr,
                    ),
                    _buildGridItem(
                      Icons.location_on_outlined,
                      "Father's Area".tr,
                      'Daskroi (Satellite)'.tr,
                    ),
                    _buildGridItem(
                      Icons.school_outlined,
                      'Last Education'.tr,
                      'B.Tech - Gujarat Univ'.tr,
                    ),
                    _buildGridItem(
                      Icons.favorite_border,
                      'Marital Status'.tr,
                      'Married'.tr,
                    ),
                    _buildGridItem(
                      Icons.phone_outlined,
                      'Mobile No'.tr,
                      '9876543210',
                      onTap: () => _launchUrl('tel:9876543210'),
                    ),
                    _buildGridItem(
                      Icons.calendar_month_outlined,
                      'Date of Marriage'.tr,
                      '10 Feb 2018',
                    ),
                    _buildGridItem(Icons.opacity, 'Gotra'.tr, 'Kashyap'.tr),
                  ];
                  return items[index];
                },
              ),
            ),

            // Address Section
            _buildSection(
              title: 'ADDRESS'.tr,
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '42, Shanti Nagar Society\nNear Satellite Road\nSatellite, Daskroi Taluka\nAhmedabad District, Gujarat\nPin: 380015'.tr,
                    style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5),
                  ),
                ],
              ),
            ),

            // Asset & Life Section
            _buildSection(
              title: 'ASSET & LIFE'.tr,
              icon: Icons.work_outline,
              child: Column(
                children: [
                  _buildAssetRow('Monthly Income'.tr, '₹75,000', 'Own House'.tr, true),
                  _buildAssetRow('Own Land'.tr, true, 'Two Wheeler'.tr, true),
                  _buildAssetRow('', '', 'Four Wheeler'.tr, false),
                ],
              ),
            ),

            // Social Media Section
            _buildSection(
              title: 'SOCIAL MEDIA'.tr,
              icon: Icons.share_outlined,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 48,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final items = [
                    _buildSocialItem(
                      Icons.facebook,
                      'Facebook'.tr,
                      'facebook.com/rajesh',
                      Colors.blue,
                      onTap: () => _launchUrl('https://facebook.com/rajesh'),
                    ),
                    _buildSocialItem(
                      Icons.camera_alt_outlined,
                      'Instagram'.tr,
                      '@rajesh_patel',
                      Colors.pink,
                      onTap: () =>
                          _launchUrl('https://instagram.com/rajesh_patel'),
                    ),
                    _buildSocialItem(
                      Icons.chat_bubble_outline,
                      'WhatsApp'.tr,
                      '+91 9876543210',
                      Colors.green,
                      onTap: () => _launchUrl('https://wa.me/919876543210'),
                    ),
                    _buildSocialItem(
                      Icons.alternate_email,
                      'Twitter / X'.tr,
                      '@rajeshpatel',
                      Colors.black,
                      onTap: () =>
                          _launchUrl('https://twitter.com/rajeshpatel'),
                    ),
                  ];
                  return items[index];
                },
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'CLOSE'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, IconData? icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ), 
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.secondary,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(String label1, dynamic value1, String label2, bool value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: label1.isNotEmpty
                ? Row(
                    children: [
                      Text(label1, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                      const Spacer(),
                      if (value1 is bool)
                        Icon(value1 ? Icons.check_circle : Icons.cancel,
                            size: 18, color: value1 ? AppColors.success : AppColors.destructive)
                      else
                        Text(value1.toString(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Row(
              children: [
                Text(label2, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                const Spacer(),
                Icon(value2 ? Icons.check_circle : Icons.cancel,
                    size: 18, color: value2 ? AppColors.success : AppColors.destructive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialItem(IconData icon, String label, String handle, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 2),
                Text(
                  handle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
