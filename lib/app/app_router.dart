import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/auth_guard.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/login_page.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/pages/reset_password_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committee_details_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committee_members_page.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/pages/committees_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_areas_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/family_members_list_page.dart';
import 'package:pscommunitymobileapp/features/family/presentation/pages/member_profile_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/home_page.dart';
import 'package:pscommunitymobileapp/features/home/presentation/pages/share_app_page.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/pages/marriage_page.dart';
import 'package:pscommunitymobileapp/features/member/presentation/pages/add_family_member_page.dart';
import 'package:pscommunitymobileapp/features/member/presentation/pages/added_members_list_page.dart';
import 'package:pscommunitymobileapp/features/member/presentation/pages/edit_profile_page.dart';
import 'package:pscommunitymobileapp/features/member/presentation/pages/find_member_page.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/pages/occupation_directory_page.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/pages/occupation_profile_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/make_payment_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payment_history_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payment_receipt_page.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/pages/payments_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/bank_account_details_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/bank_details_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/pages/samaj_sanstha_page.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/pages/community_welcome_splash_page.dart';
import 'package:pscommunitymobileapp/features/support/presentation/pages/support_page.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_sanstha_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/data/repositories/samaj_repository_impl.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/pages/notifications_page.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pscommunitymobileapp/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/services/notification_navigation_service.dart';

class AppRouter {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  static String login = '/login';
  static String home = '/home';
  static String shareApp = '/share-app';
  static String findMember = '/find-member';
  static String makePayment = '/make-payment';
  static String paymentHistory = '/payment-history';
  static String paymentReceipt = '/payment-receipt';
  static String payments = '/payments';
  static String customerSupport = '/customer-support';
  static String bankDetails = '/bank-details';
  static String bankAccountDetails = '/bank-account-details';
  static String resetPassword = '/reset-password';
  static String postLoginSplash = '/post-login-splash';
  static String familyAreas = '/family-areas';
  static String familyMembers = '/family-members';
  static String marriage = '/marriage';
  static String occupationDirectory = '/occupation-directory';
  static String committeeMembers = '/committee-members';
  static String committeeDetails = '/committee-details';
  static String committees = '/committees';
  static String occupationProfile = '/occupation-profile';
  static String memberProfile = '/member-profile';
  static String editProfile = '/edit-profile';
  static String addFamilyMember = '/add-family-member';
  static String addedMembers = '/added-members';
  static String samajSansthas = '/samaj-sansthas';
  static String notifications = '/notifications';

  static final List<GetPage<dynamic>> pages = [
    GetPage<void>(name: login, page: () => LoginPage()),
    GetPage<void>(name: resetPassword, page: () => ResetPasswordPage()),
    GetPage<void>(
      name: home,
      page: () => HomePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: shareApp,
      page: () => ShareAppPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: findMember,
      page: () => FindMemberPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: makePayment,
      page: () => MakePaymentPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: paymentHistory,
      page: () => PaymentHistoryPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: paymentReceipt,
      page: () => PaymentReceiptPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: payments,
      page: () => PaymentsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: customerSupport,
      page: () => SupportPage(),
      middlewares: [AuthGuard()],
    ),

    GetPage<void>(
      name: bankDetails,
      page: () => BankDetailsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: bankAccountDetails,
      page: () => BankAccountDetailsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: postLoginSplash,
      page: () => CommunityWelcomeSplashPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: familyAreas,
      page: () => FamilyAreasPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: familyMembers,
      page: () => FamilyMembersListPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: marriage,
      page: () => MarriagePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: occupationDirectory,
      page: () => OccupationDirectoryPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: committeeMembers,
      page: () => CommitteeMembersPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: committeeDetails,
      page: () => CommitteeDetailsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: committees,
      page: () => CommitteesPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: occupationProfile,
      page: () => OccupationProfilePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: memberProfile,
      page: () => MemberProfilePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: editProfile,
      page: () => EditProfilePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: addFamilyMember,
      page: () => AddFamilyMemberPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: addedMembers,
      page: () => AddedMembersListPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: samajSansthas,
      page: () => SamajSansthaPage(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<SamajSansthaController>(() => SamajSansthaController(SamajRepositoryImpl(Get.find<ApiClient>())));
      }),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: notifications,
      page: () => NotificationsPage(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<NotificationNavigationService>(() => NotificationNavigationService());
        Get.lazyPut<NotificationController>(() => NotificationController(NotificationRepositoryImpl(Get.find<ApiClient>()), Get.find<NotificationNavigationService>()));
      }),
      middlewares: [AuthGuard()],
    ),
  ];
}
