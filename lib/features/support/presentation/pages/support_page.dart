import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support'.tr)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Need help?'.tr,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('support_email'.tr),
              Text('support_phone'.tr),
              const SizedBox(height: 10),
              Text('support_hours'.tr),
            ],
          ),
        ),
      ),
    );
  }
}
