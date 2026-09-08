import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/models/gender_model.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_dropdown.dart';
import 'package:pscommunitymobileapp/core/widgets/app_form_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/events/controllers/event_registration_controller.dart';

class EventRegistrationPage extends GetView<EventRegistrationController> {
  final EventDetailsData event;

  const EventRegistrationPage({Key? key, required this.event})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.event_reg_title.tr),
        actions: [
          if ((event.maximumGuestsPerMember ?? 0) > 0)
            Obx(
              () => TextButton.icon(
                onPressed:
                    controller.customGuests.length <
                        (event.maximumGuestsPerMember ?? 0)
                    ? () => controller.addCustomGuest(event: event)
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
                  LK.event_details_add_guest.tr,
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
          final showGuests = controller.customGuests.isNotEmpty;
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            children: [
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  collapsedBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.05,
                  ),
                  controller: controller.membersTileController,
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  title: _buildSectionTitle(
                    LK.event_reg_my_member_list.tr,
                    Iconsax.people,
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && showGuests) {
                      controller.guestsTileController.collapse();
                    }
                  },
                  children: [_buildMemberListContainer(controller)],
                ),
              ),
              if (showGuests) SizedBox(height: 15.h),
              if (showGuests)
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                    collapsedBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.05,
                    ),
                    controller: controller.guestsTileController,
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    title: _buildSectionTitle(
                      LK.event_reg_guest_members.tr,
                      Iconsax.user_add,
                    ),
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        controller.membersTileController.collapse();
                      }
                    },
                    children: [_buildCustomGuestsList(controller)],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.w),
        SizedBox(width: 10.w),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberListContainer(EventRegistrationController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: AppTextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            hint: LK.event_reg_search_members_hint.tr,
            icon: Icons.search,
          ),
        ),
        Obx(() {
          if (controller.isLoadingMembers.value) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final members = controller.filteredFamilyMembers;

          if (members.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  controller.memberSearchQuery.value.isNotEmpty
                      ? '${LK.event_reg_no_members_match.tr} "${controller.memberSearchQuery.value}"'
                      : LK.event_reg_no_approved_members.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 0.h),
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.primary.withValues(alpha: 0.1),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final member = members[index];
              return Obx(() {
                final isSelected = controller.selectedMemberIds.contains(
                  member.memberId,
                );

                return Material(
                  color: Colors.transparent,
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
      ],
    );
  }

  Widget _buildCustomGuestsList(EventRegistrationController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.customGuests.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final guestForm = controller.customGuests[index];
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${LK.event_reg_guest_prefix.tr} ${index + 1}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.removeCustomGuest(index),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.trash_copy,
                          color: AppColors.red,
                          size: 16.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppFormTextField(
                  controller: guestForm.nameController,
                  hint: LK.event_reg_fullname_hint.tr,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.grey.shade400,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? LK.isRequired.tr : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: AppFormTextField(
                        maxLength: 2,
                        controller: guestForm.ageController,
                        hint: LK.ageColon.tr,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          color: AppColors.grey.shade400,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? LK.isRequired.tr
                            : null,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 2,
                      child: AppFormTextField(
                        maxLength: 10,
                        controller: guestForm.mobileController,
                        hint: LK.mobileNumber.tr,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppColors.grey.shade400,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? LK.isRequired.tr
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  final selectedGender = controller.genderList.firstWhereOrNull(
                    (g) => g.genderId == guestForm.selectedGenderID.value,
                  );

                  return AppFormDropdown<GenderData>(
                    value: selectedGender,
                    items: controller.genderList
                        .map(
                          (e) => DropdownMenuItem<GenderData>(
                            value: e,
                            child: Text(e.name?.tr ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        guestForm.selectedGenderID.value = v.genderId;
                        guestForm.gender.value = v.name ?? '';
                        controller.gender.value = v;
                      }
                    },
                    label: LK.gender.tr,
                    isRequired: true,
                  );
                }),
              ],
            ),
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
                  LK.cancel.tr,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.grey.shade700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isValidating.value
                      ? null
                      : () => controller.registerNow(event: event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: controller.isValidating.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          LK.event_details_register_btn.tr,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                          ),
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
