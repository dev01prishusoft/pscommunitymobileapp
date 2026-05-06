import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy Policy'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('privacy_content'.tr),
      ),
    );
  }
}
