import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'This is a basic privacy page scaffold.\n\n'
          'Replace this content with your official privacy policy, including:\n'
          '- data collected\n'
          '- usage purpose\n'
          '- retention policy\n'
          '- contact information',
        ),
      ),
    );
  }
}
