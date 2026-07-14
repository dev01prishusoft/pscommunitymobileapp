import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

bool isUpdateSheetOpen = false;

void showAppUpdateBottomSheet(
  BuildContext context, {
  required bool forceUpdate,
  required String androidUrl,
  required String iosUrl,
}) {
  if (isUpdateSheetOpen) return;

  isUpdateSheetOpen = true;
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(Icons.system_update_rounded),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LK.appTitle.tr,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        LK.newUpdateAvailable.tr,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                LK.updateDescription.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _openStore(androidUrl: androidUrl, iosUrl: iosUrl);
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LK.update.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (forceUpdate == false) ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    LK.notNow.tr,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  ).whenComplete(() {
    isUpdateSheetOpen = false;
  });
}

void _openStore({required String androidUrl, required String iosUrl}) async {
  await SecureStorageService().setBool(LK.wentForUpdate, true);

  final Uri url = Platform.isAndroid
      ? Uri.parse(androidUrl)
      : Uri.parse(iosUrl);

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

bool isVersionGreater(String latest, String current) {
  final List<int> latestParts = latest
      .split('.')
      .map((e) => int.tryParse(e) ?? 0)
      .toList();
  final List<int> currentParts = current
      .split('.')
      .map((e) => int.tryParse(e) ?? 0)
      .toList();

  for (int i = 0; i < latestParts.length; i++) {
    if (latestParts[i] > currentParts[i]) return true;
    if (latestParts[i] < currentParts[i]) return false;
  }
  return false;
}
