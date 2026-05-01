import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Center(
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Need help?\n\n'
            'Email: support@yourdomain.com\n'
            'Phone: +91-00000-00000\n'
            'Working hours: 10:00 AM - 6:00 PM',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
