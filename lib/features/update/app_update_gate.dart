import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class AppUpdateGate extends StatelessWidget {
  final Widget child;

  const AppUpdateGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(hours: 12),
        messages: CustomUpgraderMessages(),
      ),
      child: child,
    );
  }
}

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.title:
        return LK.updateAvailable.tr;
      case UpgraderMessage.body:
        return 'A new version is available!'.tr;
      case UpgraderMessage.prompt:
        return 'Would you like to update now?'.tr;
      case UpgraderMessage.releaseNotes:
        return 'Release Notes'.tr;
      case UpgraderMessage.buttonTitleUpdate:
        return LK.updateNow.tr;
      case UpgraderMessage.buttonTitleLater:
        return LK.updateLater.tr;
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignore'.tr;
    }
  }
}
