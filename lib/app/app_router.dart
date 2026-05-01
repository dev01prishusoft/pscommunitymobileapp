import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/login_page.dart';
import 'package:pscommunitymobileapp/features/business/presentation/pages/business_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/home_page.dart';
import 'package:pscommunitymobileapp/features/privacy/presentation/pages/privacy_page.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/pages/post_login_splash_page.dart';
import 'package:pscommunitymobileapp/features/support/presentation/pages/support_page.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/reset_password_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_areas_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_members_list_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String privacy = '/privacy';
  static const String support = '/support';
  static const String business = '/business';
  static const String resetPassword = '/reset-password';
  static const String postLoginSplash = '/post-login-splash';
  static const String familyAreas = '/family-areas';
  static const String familyMembers = '/family-members';

  static final Map<String, WidgetBuilder> routes = {
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
        privacy: (_) => const PrivacyPage(),
        support: (_) => const SupportPage(),
    business: (_) => const BusinessPage(),
    resetPassword: (_) => const ResetPasswordPage(),
    postLoginSplash: (_) => const PostLoginSplashPage(),
    familyAreas: (_) => const FamilyAreasPage(),
    familyMembers: (_) => const FamilyMembersListPage(),
      };
}
