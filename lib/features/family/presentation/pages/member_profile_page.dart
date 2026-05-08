import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  final FamilyController _controller = Get.find<FamilyController>();
  int _memberId = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('memberId')) {
      _memberId = args['memberId'] as int;
      _controller.loadMemberDetails(_memberId);
    } else {
      _controller.selectedMember.value = null;
      _controller.memberDetailState.value = AppState.loading;
    }
  }

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
          LK.memberDetails.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back<void>(),
          ),
        ],
      ),
      body: Obx(() => AppStateView(
            state: _controller.memberDetailState.value,
            onRetry: () => _controller.loadMemberDetails(_memberId),
            child: _buildProfileContent(),
          )),
    );
  }

  Widget _buildProfileContent() {
    final member = _controller.selectedMember.value;
    if (member == null) return const SizedBox.shrink();

    return SingleChildScrollView(
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
                  child: member.profilePhotoFullUrl != null &&
                          member.profilePhotoFullUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: member.profilePhotoFullUrl!,
                          imageBuilder: (context, ImageProvider imageProvider) => CircleAvatar(
                            radius: 40,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => const CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.muted,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.muted,
                            child: Icon(Icons.person,
                                size: 50, color: AppColors.primary.withValues(alpha: 0.5)),
                          ),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.muted,
                          child: Icon(Icons.person,
                              size: 50, color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.memberNo ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                          fontFamily: 'monospace',
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
                              (member.jobPositionName ?? 'Member').tr,
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
              itemCount: 14,
              itemBuilder: (context, index) {
                final items = [
                  _buildGridItem(
                    Icons.person_outline,
                    LK.gender.tr,
                    (member.genderName ?? LK.na).tr,
                  ),
                  _buildGridItem(
                    Icons.water_drop_outlined,
                    LK.bloodGroupColon.tr,
                    member.bloodGroupName ?? LK.na,
                  ),
                  _buildGridItem(
                    Icons.calendar_today_outlined,
                    LK.birthDate.tr,
                    member.dateOfBirth != null
                        ? member.dateOfBirth!.split('T')[0]
                        : LK.na,
                  ),
                  _buildGridItem(Icons.height, LK.heightColon.tr, '${member.height ?? 0} cm'),
                  _buildGridItem(
                    Icons.access_time,
                    'Birth Time'.tr, // I'll add this to LK if needed
                    member.dateOfBirthTime ?? LK.na,
                  ),
                  _buildGridItem(
                    Icons.monitor_weight_outlined,
                    LK.weightColon.tr,
                    '${member.weight ?? 0} kg',
                  ),
                  _buildGridItem(
                    Icons.person_outline,
                    "Mother/Father's Name".tr,
                    (member.motherFatherName ?? LK.na).tr,
                  ),
                  _buildGridItem(
                    Icons.work_outline,
                    LK.occupationLabel.tr,
                    (member.occupationName ?? member.occupationTypeName ?? LK.na).tr,
                  ),
                  _buildGridItem(
                    Icons.location_on_outlined,
                    "Occupation Area".tr,
                    (member.occupationAreaName ?? LK.na).tr,
                  ),
                  _buildGridItem(
                    Icons.favorite_border,
                    LK.maritalStatusLabel.tr,
                    (member.maritalStatusName ?? LK.na).tr,
                  ),
                  _buildGridItem(
                    Icons.phone_outlined,
                    LK.mobileNoLabel.tr,
                    member.mobileNo ?? LK.na,
                    onTap: member.mobileNo != null ? () => _launchUrl('tel:${member.mobileNo}') : null,
                  ),
                  _buildGridItem(
                    Icons.contact_phone_outlined,
                    LK.emergencyContact.tr,
                    member.emergencyContactNo ?? LK.na,
                    onTap: member.emergencyContactNo != null ? () => _launchUrl('tel:${member.emergencyContactNo}') : null,
                  ),
                  _buildGridItem(Icons.opacity, LK.gotraLabel.tr, (member.gotraName ?? LK.na).tr),
                  _buildGridItem(Icons.mail_outline, LK.email.tr, member.emailAddress ?? LK.na),
                ];
                return items[index];
              },
            ),
          ),

          // Address Section
          if (_controller.memberAddresses.isNotEmpty)
            _buildSection(
            title: LK.memberAddresses.tr,
            icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _controller.memberAddresses.map((addr) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                addr.addressTypeName.tr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (addr.isPrimary) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addr.fullAddress,
                          style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5),
                        ),
                        if (_controller.memberAddresses.last != addr)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Divider(height: 1),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Asset & Life Section
          _buildSection(
            title: LK.assetAndLife.tr,
            icon: Icons.work_outline,
            child: Column(
              children: [
                _buildAssetRow(LK.incomeColon.tr, '₹${member.monthlyIncome ?? 0}', 'Own House'.tr, member.isOwnHouse ?? false),
                _buildAssetRow('Own Land'.tr, member.isOwnLand ?? false, 'Two Wheeler'.tr, member.hasTwoWheeler ?? false),
                _buildAssetRow('', '', 'Four Wheeler'.tr, member.hasFourWheeler ?? false),
              ],
            ),
          ),

          // Social Media Section
          _buildSection(
            title: LK.socialMedia.tr,
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
                    LK.facebook.tr,
                    member.facebookUrl ?? LK.na,
                    Colors.blue,
                    onTap: member.facebookUrl != null ? () => _launchUrl(member.facebookUrl!) : null,
                  ),
                  _buildSocialItem(
                    Icons.camera_alt_outlined,
                    LK.instagram.tr,
                    member.instagramUrl ?? LK.na,
                    Colors.pink,
                    onTap: member.instagramUrl != null ? () => _launchUrl(member.instagramUrl!) : null,
                  ),
                  _buildSocialItem(
                    Icons.chat_bubble_outline,
                    LK.whatsapp.tr,
                    member.whatsappUrl ?? LK.na,
                    Colors.green,
                    onTap: member.whatsappUrl != null ? () => _launchUrl(member.whatsappUrl!) : null,
                  ),
                  _buildSocialItem(
                    Icons.alternate_email,
                    'Twitter / X'.tr,
                    member.twitterUrl ?? LK.na,
                    Colors.black,
                    onTap: member.twitterUrl != null ? () => _launchUrl(member.twitterUrl!) : null,
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
              onPressed: () => Get.back<void>(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                LK.close.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
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
