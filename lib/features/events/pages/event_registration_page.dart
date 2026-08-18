import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_registration_controller.dart';

class EventRegistrationPage extends StatelessWidget {
  final EventDetailsData event;

  const EventRegistrationPage({Key? key, required this.event})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventRegistrationController(event: event));

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Registration'),
        actions: [
          if ((event.maximumGuestsPerMember ?? 0) > 0)
            Obx(
              () => TextButton.icon(
                onPressed:
                    controller.customGuests.length <
                        (event.maximumGuestsPerMember ?? 0)
                    ? controller.addCustomGuest
                    : null,
                icon: Icon(
                  Icons.add,
                  color:
                      controller.customGuests.length <
                          (event.maximumGuestsPerMember ?? 0)
                      ? AppColors.primary
                      : AppColors.grey,
                  size: 18.w,
                ),
                label: Text(
                  'Add Guest',
                  style: TextStyle(
                    color:
                        controller.customGuests.length <
                            (event.maximumGuestsPerMember ?? 0)
                        ? AppColors.primary
                        : AppColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomStaticBar(controller),
      body: Form(
        key: controller.formKey,
        child: Obx(() {
          final showMembers = controller.isLoadingMembers.value || controller.familyMembers.isNotEmpty;
          final showGuests = controller.customGuests.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showMembers)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('My Member List').paddingOnly(left: 5.w),
                      SizedBox(height: 15.h),
                      Expanded(child: _buildMemberListContainer(controller)),
                    ],
                  ),
                ),
              if (showMembers && showGuests) SizedBox(height: 15.h),
              if (showGuests)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Guest Members').paddingOnly(left: 5.w),
                      SizedBox(height: 15.h),
                      Expanded(child: _buildCustomGuestsList(controller)),
                    ],
                  ),
                ),
            ],
          ).paddingSymmetric(horizontal: 20.w, vertical: 15.h);
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMemberListContainer(EventRegistrationController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: AppTextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              hint: 'Search members...',
              icon: Icons.search,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMembers.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final members = controller.filteredFamilyMembers;
              
              if (members.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Text(
                      controller.memberSearchQuery.value.isNotEmpty
                          ? 'No members found matching "${controller.memberSearchQuery.value}"'
                          : 'No approved family members found.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
    
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 0.h),
                itemCount: members.length,
                separatorBuilder: (context, index) =>
                    Divider(color: AppColors.grey.shade300, height: 1),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Obx(() {
                    final isSelected = controller.selectedMemberIds.contains(
                      member.memberId,
                    );
    
                    return Material(
                      color: AppColors.transparent,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        leading: SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: ClipOval(
                            child: CachedImg(
                              url: member.profilePhotoFullUrl ?? '',
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  size: 24.w,
                                  color: AppColors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          member.fullName,
                          style: AppTextStyles.bodyLarge,
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (val) =>
                              controller.toggleMemberSelection(member.memberId),
                          activeColor: AppColors.primary,
                        ),
                        onTap: () =>
                            controller.toggleMemberSelection(member.memberId),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomGuestsList(EventRegistrationController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.customGuests.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final textController = controller.customGuests[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: textController,
                  hint: 'Full Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.grey.shade400,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required field' : null,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () => controller.removeCustomGuest(index),
                icon: Icon(
                  Iconsax.trash_copy,
                  color: AppColors.red,
                  size: 24.w,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomStaticBar(EventRegistrationController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.grey.shade700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.registerNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Register Now',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
