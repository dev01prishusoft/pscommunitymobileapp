import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.privacyPolicy.tr)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(LK.privacyContent.tr),
      ),
    );
  }
}
