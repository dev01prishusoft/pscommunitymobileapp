import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/login_page.dart';
import 'package:pscommunitymobileapp/features/business/presentation/pages/business_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/home_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/share_app_page.dart';
import 'package:pscommunitymobileapp/features/member/presentation/pages/find_member_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/make_payment_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payment_history_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payment_receipt_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payments_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/samaj_profile_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/samaj_sanstha_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/bank_details_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/bank_account_details_page.dart';
import 'package:pscommunitymobileapp/features/privacy/presentation/pages/privacy_page.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/pages/post_login_splash_page.dart';
import 'package:pscommunitymobileapp/features/support/presentation/pages/support_page.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/reset_password_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_areas_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_members_list_page.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/pages/marriage_page.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/pages/occupation_directory_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committee_members_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committee_details_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committees_page.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/pages/occupation_profile_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/member_profile_page.dart';

import 'package:pscommunitymobileapp/app/auth_guard.dart';
import 'package:get/get.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String shareApp = '/share-app';
  static const String findMember = '/find-member';
  static const String makePayment = '/make-payment';
  static const String paymentHistory = '/payment-history';
  static const String paymentReceipt = '/payment-receipt';
  static const String payments = '/payments';
  static const String samajProfile = '/samaj-profile';
  static const String samajSanstha = '/samaj-sanstha';
  static const String bankDetails = '/bank-details';
  static const String bankAccountDetails = '/bank-account-details';
  static const String privacy = '/privacy';
  static const String support = '/support';
  static const String business = '/business';
  static const String resetPassword = '/reset-password';
  static const String postLoginSplash = '/post-login-splash';
  static const String familyAreas = '/family-areas';
  static const String familyMembers = '/family-members';
  static const String marriage = '/marriage';
  static const String occupationDirectory = '/occupation-directory';
  static const String committeeMembers = '/committee-members';
  static const String committeeDetails = '/committee-details';
  static const String committees = '/committees';
  static const String occupationProfile = '/occupation-profile';
  static const String memberProfile = '/member-profile';

  static final List<GetPage> pages = [
    // Public Routes
    GetPage<void>(name: login, page: () => const LoginPage()),
    GetPage<void>(name: resetPassword, page: () => const ResetPasswordPage()),
    
    // Protected Routes
    GetPage<void>(name: home, page: () => HomePage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: shareApp, page: () => const ShareAppPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: findMember, page: () => const FindMemberPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: makePayment, page: () => const MakePaymentPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: paymentHistory, page: () => const PaymentHistoryPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: paymentReceipt, page: () => const PaymentReceiptPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: payments, page: () => const PaymentsPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: samajProfile, page: () => const SamajProfilePage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: samajSanstha, page: () => const SamajSansthaPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: bankDetails, page: () => const BankDetailsPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: bankAccountDetails, page: () => const BankAccountDetailsPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: privacy, page: () => const PrivacyPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: support, page: () => const SupportPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: business, page: () => const BusinessPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: postLoginSplash, page: () => const PostLoginSplashPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: familyAreas, page: () => const FamilyAreasPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: familyMembers, page: () => const FamilyMembersListPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: marriage, page: () => const MarriagePage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: occupationDirectory, page: () => const OccupationDirectoryPage(), middlewares: [AuthGuard()]),
    GetPage<void>(
      name: committeeMembers,
      page: () => const CommitteeMembersPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(name: committeeDetails, page: () => const CommitteeDetailsPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: committees, page: () => const CommitteesPage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: occupationProfile, page: () => const OccupationProfilePage(), middlewares: [AuthGuard()]),
    GetPage<void>(name: memberProfile, page: () => const MemberProfilePage(), middlewares: [AuthGuard()]),
  ];
}
