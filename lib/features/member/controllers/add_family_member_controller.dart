import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/member/controllers/profile_form_controller.dart';

class AddFamilyMemberController extends ProfileFormController {
  // Id of the family member being edited (never the logged-in user's id).
  int? editingMemberId;
  Future<void>? _statusFuture;

  Future<bool> loadMemberForEdit(int memberId) async {
    editingMemberId = memberId;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getParsed<Member>(
        '/api/v1/member/$memberId',
        fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
      );

      final member = response.dataOrNull?.data;
      if (member != null) {
        loadFromMember(member);
        await _statusFuture;
        return true;
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason:
            'AddFamilyMemberController.loadMemberForEdit failed for member $memberId',
      );
    }
    return false;
  }

  // The base version reads the logged-in user's statuses; load the edited member's instead.
  @override
  Future<void> fetchProfileUpdateStatus() {
    return _statusFuture = _fetchMemberUpdateStatus();
  }

  Future<void> _fetchMemberUpdateStatus() async {
    final memberId = editingMemberId;
    if (memberId == null) return;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        '/api/v1/MemberUpdateRequest/member-details/$memberId',
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['succeeded'] == true) {
        final data = response.data['data'];
        final items = data is Map<String, dynamic>
            ? data['items'] as List<dynamic>? ?? []
            : data is List<dynamic>
            ? data
            : <dynamic>[];

        final newStatuses = <String, ProfileUpdateStatus>{};
        for (final item in items) {
          if (item is! Map<String, dynamic>) continue;
          final status = ProfileUpdateStatus.fromJson(item);
          if (status.keyName.isEmpty) continue;
          newStatuses[status.keyName] = status;
        }

        fieldStatuses.value = newStatuses;
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'AddFamilyMemberController.fetchProfileUpdateStatus failed for member $memberId',
      );
    }
  }

  void updateMember({String? successMessage}) {
    final memberId = editingMemberId;
    if (memberId == null || currentMember == null) return;
    bool hasListErrors = false;

    if (contactInfo.addresses.isEmpty) {
      hasListErrors = true;
    }

    showListErrors.value = hasListErrors;

    if (!hasListErrors && (formKey.currentState?.validate() ?? false)) {
      personalInfo.firstName.value = personalInfo.firstNameCtrl.text;
      personalInfo.lastName.value = personalInfo.lastNameCtrl.text;

      submitThrottled(() async {
        personalInfo.uploadProgress.value = 0.1;

        try {
          final formDataMap = <String, dynamic>{};

          formDataMap.addAll(changedFormData);
          if (personalInfo.profileImage.value != null) {
            final file = personalInfo.profileImage.value!;
            final fileName = file.path.split('/').last;
            formDataMap['ProfileImage'] = await dio.MultipartFile.fromFile(
              file.path,
              filename: fileName,
            );
          } else if (personalInfo.isPhotoRemoved.value) {
            formDataMap['ProfileImage'] = null;
            formDataMap['ProfilePhotoPath'] = null;
          }
          formDataMap.removeWhere((key, value) => key.startsWith('_dummy_'));

          final apiClient = Get.find<ApiClient>();
          final bool hasProfileUpdates = formDataMap.isNotEmpty;
          bool hasEducationUpdates = false;

          if (hasProfileUpdates) {
            formDataMap['MemberId'] = memberId;

            final formData = dio.FormData.fromMap(formDataMap);
            final response = await apiClient.post(
              '/api/v1/MemberUpdateRequest/create',
              data: formData,
            );

            if (response.data != null &&
                response.data is Map<String, dynamic>) {
              final msg = response.data['message'] as String?;
              if (msg != null && msg.isNotEmpty) {
                successMessage = msg.tr;
              }
            }
          }

          final currentEduJson = jsonEncode(
            educationList.map((e) => e.toJson()).toList(),
          );
          if (currentEduJson != initialEducationJson) {
            final newEducations =
                contactInfo.educationList.where((e) => e.isNew).toList();
            if (newEducations.isNotEmpty) {
              hasEducationUpdates = true;
              try {
                final educationsPayload = {
                  "memberId": memberId,
                  "educations": newEducations.map((edu) {
                    return {
                      "memberEducationId": 0,
                      "memberId": memberId,
                      "educationalQualificationId":
                          contactInfo.educationIdMap[edu.qualification] ??
                              edu.qualificationId ??
                              0,
                      "description": edu.description,
                      "institutionName": edu.institute,
                      "yearOfPassing": int.tryParse(edu.passingYear) ?? 0,
                      "percentage": double.tryParse(edu.percentage) ?? 0,
                      "grade": edu.grade,
                      "isHighestQualification": edu.isHighest,
                      "isActive": true,
                    };
                  }).toList(),
                };
                await apiClient.post(
                  '/api/v1/MemberEducation/mobile/upsert',
                  data: educationsPayload,
                );
              } catch (e, stack) {
                CrashReporter.recordError(
                  e,
                  stack,
                  reason:
                      'AddFamilyMemberController.updateMember MemberEducation/mobile/upsert failed',
                );
              }
            }
          }

          if (!hasProfileUpdates && !hasEducationUpdates) {
            PSDelightToastBar(
              snackbarDuration: const Duration(seconds: 3),
              builder: (context) => ToastCard(
                title: LK.error.tr,
                subtitle: 'No member changes found.'.tr,
                isErrorMessage: true,
              ),
            ).show();
            return;
          }

          String snackbarMsg =
              successMessage ?? LK.memberUpdatedSuccessfully.tr;
          if (hasProfileUpdates && hasEducationUpdates) {
            snackbarMsg = LK.profileAndEducationUpdated.tr;
          } else if (hasEducationUpdates && !hasProfileUpdates) {
            snackbarMsg = LK.educationAddedSuccessfully.tr;
          }

          PSDelightToastBar(
            snackbarDuration: const Duration(seconds: 3),
            builder: (context) =>
                ToastCard(title: LK.success.tr, subtitle: snackbarMsg),
          ).show();

          await Future<void>.delayed(const Duration(milliseconds: 1500));
          Get.back<dynamic>(result: true);
        } catch (e) {
          String errorMessage = LK.unexpectedError.tr;
          if (e is Failure) {
            if (e.message == 'No member changes found.') {
              errorMessage = e.message.tr;
            } else {
              errorMessage = e.message;
            }
          }
          PSDelightToastBar(
            snackbarDuration: const Duration(seconds: 3),
            builder: (context) => ToastCard(
              title: LK.error.tr,
              subtitle: errorMessage,
              isErrorMessage: true,
            ),
          ).show();
        } finally {
          personalInfo.uploadProgress.value = 0.0;
        }
      });
    } else {
      showListErrors.value = true;
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          title: LK.errorValidation.tr,
          subtitle: LK.pleaseFillRequiredFields.tr,
          isErrorMessage: true,
        ),
      ).show();
    }
  }
}
