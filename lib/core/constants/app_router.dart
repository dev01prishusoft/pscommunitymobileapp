import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_guard.dart';
import 'package:pscommunitymobileapp/core/module_permission/module_permission.dart';
import 'package:pscommunitymobileapp/features/auth/pages/login_page.dart';
import 'package:pscommunitymobileapp/features/auth/pages/reset_password_page.dart';
import 'package:pscommunitymobileapp/features/committee/pages/committee_details_page.dart';
import 'package:pscommunitymobileapp/features/committee/pages/committee_members_page.dart';
import 'package:pscommunitymobileapp/features/committee/pages/committees_page.dart';
import 'package:pscommunitymobileapp/features/committee/pages/frompage_committee.dart';
import 'package:pscommunitymobileapp/features/events/pages/events_page.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_registration_page.dart';
import 'package:pscommunitymobileapp/features/events/pages/my_events_page.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/features/family/pages/family_areas_page.dart';
import 'package:pscommunitymobileapp/features/family/pages/family_members_list_page.dart';
import 'package:pscommunitymobileapp/features/family/pages/family_tree_page.dart';
import 'package:pscommunitymobileapp/features/family/pages/member_profile_page.dart';
import 'package:pscommunitymobileapp/features/home/pages/home_page.dart';
import 'package:pscommunitymobileapp/features/home/pages/share_app_page.dart';
import 'package:pscommunitymobileapp/features/marriage/pages/marriage_page.dart';
import 'package:pscommunitymobileapp/features/member/pages/add_family_member_page.dart';
import 'package:pscommunitymobileapp/features/member/pages/added_members_list_page.dart';
import 'package:pscommunitymobileapp/features/member/pages/edit_profile_page.dart';
import 'package:pscommunitymobileapp/features/member/pages/find_member_page.dart';
import 'package:pscommunitymobileapp/features/occupation/pages/frompage_occupation.dart';
import 'package:pscommunitymobileapp/features/occupation/pages/occupation_directory_page.dart';
import 'package:pscommunitymobileapp/features/occupation/pages/occupation_profile_page.dart';
import 'package:pscommunitymobileapp/features/payment/pages/make_payment_page.dart';
import 'package:pscommunitymobileapp/features/payment/pages/payment_history_page.dart';
import 'package:pscommunitymobileapp/features/payment/pages/payment_receipt_page.dart';
import 'package:pscommunitymobileapp/features/payment/pages/payments_page.dart';
import 'package:pscommunitymobileapp/features/samaj/pages/bank_account_details_page.dart';
import 'package:pscommunitymobileapp/features/samaj/pages/bank_details_page.dart';
import 'package:pscommunitymobileapp/features/samaj/pages/samaj_sanstha_page.dart';
import 'package:pscommunitymobileapp/features/splash/pages/community_welcome_splash_page.dart';
import 'package:pscommunitymobileapp/features/support/pages/support_page.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_sanstha_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/repositories/samaj_repository_impl.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/notification/pages/notifications_page.dart';
import 'package:pscommunitymobileapp/features/notification/controllers/notification_controller.dart';
import 'package:pscommunitymobileapp/features/notification/repositories/notification_repository_impl.dart';
import 'package:pscommunitymobileapp/core/services/notification_navigation_service.dart';
import 'package:pscommunitymobileapp/core/widgets/network_error_page.dart';
import 'package:pscommunitymobileapp/features/advertisement/pages/advertisement_detail_page.dart';
import 'package:pscommunitymobileapp/features/advertisement/pages/advertisement_list_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_categories_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_items_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_pdf_viewer_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_text_viewer_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_video_player_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_image_viewer_page.dart';
import 'package:pscommunitymobileapp/features/library/pages/library_audio_player_page.dart';

class AppRouter {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

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
  static String familyTree = '/family-tree';
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
  static String frompageOccupation = '/frompageOccupation';
  static String frompageCommittee = '/frompageCommittee';
  static String events = '/events';
  static String eventRegistration = '/event-registration';
  static String myEvents = '/my-events';
  static String eventScanner = '/event-scanner';
  static String networkError = '/network-error';
  static String advertisementList = '/advertisement-list';
  static String advertisementDetail = '/advertisement-detail';
  static String libraryCategories = '/library';
  static String libraryItems = '/library-items';
  static String libraryPdf = '/library-pdf';
  static String libraryText = '/library-text';
  static String libraryVideo = '/library-video';
  static String libraryImage = '/library-image';
  static String libraryAudio = '/library-audio';

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
      middlewares: [AuthGuard(), ModuleGuard(AppModule.payment)],
    ),
    GetPage<void>(
      name: paymentHistory,
      page: () => PaymentHistoryPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.payment)],
    ),
    GetPage<void>(
      name: paymentReceipt,
      page: () => PaymentReceiptPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.payment)],
    ),
    GetPage<void>(
      name: payments,
      page: () => PaymentsPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.payment)],
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
      name: familyTree,
      page: () => const FamilyTreePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: marriage,
      page: () => MarriagePage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.matrimonial)],
    ),
    GetPage<void>(
      name: occupationDirectory,
      page: () => OccupationDirectoryPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.occupation)],
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
      middlewares: [AuthGuard(), ModuleGuard(AppModule.occupation)],
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
        Get.lazyPut<SamajSansthaController>(
          () => SamajSansthaController(
            SamajRepositoryImpl(Get.find<ApiClient>()),
          ),
        );
      }),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: notifications,
      page: () => NotificationsPage(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<NotificationNavigationService>(
          () => NotificationNavigationService(),
        );
        Get.lazyPut<NotificationController>(
          () => NotificationController(
            NotificationRepositoryImpl(Get.find<ApiClient>()),
            Get.find<NotificationNavigationService>(),
          ),
        );
      }),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.dailyNotification)],
    ),
    GetPage<void>(
      name: frompageOccupation,
      page: () => FromPageOccupation(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.occupation)],
    ),
    GetPage<void>(
      name: frompageCommittee,
      page: () => FromPageCommittee(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: events,
      page: () => EventsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: eventRegistration,
      page: () {
        final event = Get.arguments as EventDetailsData;
        return EventRegistrationPage(event: event);
      },
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: myEvents,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic>) {
          return MyEventsPage(
            targetEventId: args['targetEventId'] as int?,
            targetEventName: args['targetEventName'] as String?,
            targetStatus: args['targetStatus'] as String?,
          );
        }
        return const MyEventsPage();
      },
      middlewares: [AuthGuard()],
    ),
    GetPage<void>(
      name: networkError,
      page: () => const NetworkErrorPage(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: advertisementList,
      page: () => const AdvertisementListPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.advertisement)],
    ),
    GetPage<void>(
      name: advertisementDetail,
      page: () => const AdvertisementDetailPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.advertisement)],
    ),
    GetPage<void>(
      name: libraryCategories,
      page: () => const LibraryCategoriesPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryItems,
      page: () => const LibraryItemsPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryPdf,
      page: () => const LibraryPdfViewerPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryText,
      page: () => const LibraryTextViewerPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryVideo,
      page: () => const LibraryVideoPlayerPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryImage,
      page: () => const LibraryImageViewerPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
    GetPage<void>(
      name: libraryAudio,
      page: () => const LibraryAudioPlayerPage(),
      middlewares: [AuthGuard(), ModuleGuard(AppModule.library)],
    ),
  ];
}
