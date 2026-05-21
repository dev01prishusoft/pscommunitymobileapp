import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
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
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: SafeArea(
        child: Obx(() => AppStateView(
              state: _controller.memberDetailState.value,
              onRetry: () => _controller.loadMemberDetails(_memberId),
              child: const _ProfileContent(),
            )),
      ),
      bottomNavigationBar: Obx(() => _controller.memberDetailState.value == AppState.data 
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Get.back<void>(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LK.close.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}

Future<void> launchSafeUrl(String urlString) async {
  try {
    final Uri url = Uri.parse(urlString);
    if (urlString.startsWith('tel:')) {
      final String number = urlString.replaceFirst('tel:', '');
      final Uri telUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      }
    } else {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  } catch (e) {
    debugPrint('Could not launch URL: $e');
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();
    final member = controller.selectedMember.value;
    if (member == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _ProfileHeader(member: member),
          _MemberDetailsSection(member: member, controller: controller),
          if (controller.memberAddresses.isNotEmpty)
            _AddressSection(controller: controller),
          _AssetLifeSection(member: member),
          _SocialMediaSection(member: member),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Member member;

  const _ProfileHeader({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: MemberAvatar(
              imageUrl: member.profilePhotoFullUrl,
              gender: member.gender,
              fallbackName: member.fullName,
              radius: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
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
                        member.jobPositionName ?? 'Member',
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
    );
  }
}

class _MemberDetailsSection extends StatelessWidget {
  final Member member;
  final FamilyController controller;

  const _MemberDetailsSection({required this.member, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        children: [
          _buildDetailRow(
            _buildGridItem(Icons.person_outline, LK.gender.tr, (member.genderName ?? LK.na).tr),
            _buildGridItem(Icons.water_drop_outlined, LK.bloodGroupColon.tr, member.bloodGroupName ?? LK.na),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.calendar_today_outlined, LK.birthDate.tr, controller.getFormattedDateOfBirth(member)),
            _buildGridItem(Icons.height, LK.heightColon.tr, '${member.height ?? 0} cm'),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.access_time, LK.birthTime.tr, member.dateOfBirthTime ?? LK.na),
            _buildGridItem(Icons.monitor_weight_outlined, LK.weightColon.tr, '${member.weight ?? 0} kg'),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.person_outline, LK.motherFatherName.tr, member.motherFatherName ?? LK.na),
            _buildGridItem(Icons.work_outline, LK.occupationLabel.tr, member.occupationName ?? member.occupationTypeName ?? LK.na),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.location_on_outlined, LK.occupationArea.tr, member.occupationAreaName ?? LK.na),
            _buildGridItem(Icons.favorite_border, LK.maritalStatusLabel.tr, (member.maritalStatusName ?? LK.na).tr),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.phone_outlined, LK.mobileNoLabel.tr, member.mobileNo ?? LK.na, onTap: member.mobileNo != null ? () => launchSafeUrl('tel:${member.mobileNo}') : null),
            _buildGridItem(Icons.contact_phone_outlined, LK.emergencyContact.tr, member.emergencyContactNo ?? LK.na, onTap: member.emergencyContactNo != null ? () => launchSafeUrl('tel:${member.emergencyContactNo}') : null),
          ),
          _buildDetailRow(
            _buildGridItem(Icons.opacity, LK.gotraLabel.tr, member.gotraName ?? LK.na),
            _buildGridItem(Icons.mail_outline, LK.email.tr, member.emailAddress ?? LK.na),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(Widget item1, Widget item2, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: item1),
          const SizedBox(width: 12),
          Expanded(child: item2),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  final FamilyController controller;

  const _AddressSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.memberAddresses.tr,
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.memberAddresses.map((addr) {
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
                        addr.addressTypeName,
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
                if (controller.memberAddresses.last != addr)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Divider(height: 1),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssetLifeSection extends StatelessWidget {
  final Member member;

  const _AssetLifeSection({required this.member});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.assetAndLife.tr,
      icon: Icons.work_outline,
      child: Column(
        children: [
          _buildAssetRow(LK.incomeColon.tr, '₹${member.monthlyIncome ?? 0}', LK.ownHouse.tr, member.isOwnHouse ?? false),
          _buildAssetRow(LK.ownLand.tr, member.isOwnLand ?? false, LK.twoWheeler.tr, member.hasTwoWheeler ?? false),
          _buildAssetRow('', '', LK.fourWheeler.tr, member.hasFourWheeler ?? false),
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
}

class _SocialMediaSection extends StatelessWidget {
  final Member member;

  const _SocialMediaSection({required this.member});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.socialMedia.tr,
      icon: Icons.share_outlined,
      child: Column(
        children: [
          _buildSocialRow(
            _buildSocialItem(Icons.facebook, LK.facebook.tr, member.facebookUrl ?? LK.na, Colors.blue, onTap: member.facebookUrl != null ? () => launchSafeUrl(member.facebookUrl!) : null),
            _buildSocialItem(Icons.camera_alt_outlined, LK.instagram.tr, member.instagramUrl ?? LK.na, Colors.pink, onTap: member.instagramUrl != null ? () => launchSafeUrl(member.instagramUrl!) : null),
          ),
          _buildSocialRow(
            _buildSocialItem(Icons.chat_bubble_outline, LK.whatsapp.tr, member.whatsappUrl ?? LK.na, Colors.green, onTap: member.whatsappUrl != null ? () => launchSafeUrl(member.whatsappUrl!) : null),
            _buildSocialItem(Icons.alternate_email, LK.twitterX.tr, member.twitterUrl ?? LK.na, Colors.black, onTap: member.twitterUrl != null ? () => launchSafeUrl(member.twitterUrl!) : null),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(Widget item1, Widget item2, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: item1),
          const SizedBox(width: 12),
          Expanded(child: item2),
        ],
      ),
    );
  }

  Widget _buildSocialItem(IconData icon, String label, String handle, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 2),
                Text(
                  handle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;

  const _SectionContainer({this.title, this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
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
                  title!,
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
}
