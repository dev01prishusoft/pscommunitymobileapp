import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/login_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/home_page.dart';
import 'package:pscommunitymobileapp/features/privacy/presentation/pages/privacy_page.dart';
import 'package:pscommunitymobileapp/features/support/presentation/pages/support_page.dart';

class AppRouter {
  static const String login = '/';
  static const String home = '/home';
  static const String privacy = '/privacy';
  static const String support = '/support';

  static final Map<String, WidgetBuilder> routes = {
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
        privacy: (_) => const PrivacyPage(),
        support: (_) => const SupportPage(),
      };
}
