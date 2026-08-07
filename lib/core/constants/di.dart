import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/auth/session_manager.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/services/push_notification_service.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/auth/repositories/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/features/auth/repositories/login_usecase.dart';
import 'package:pscommunitymobileapp/features/auth/controllers/reset_password_controller.dart';
import 'package:pscommunitymobileapp/features/business/repositories/business_repository_impl.dart';
import 'package:pscommunitymobileapp/features/business/controllers/business_controller.dart';
import 'package:pscommunitymobileapp/features/committee/repositories/committee_repository_impl.dart';
import 'package:pscommunitymobileapp/features/committee/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/events/controllers/events_controller.dart';
import 'package:pscommunitymobileapp/features/family/repositories/family_repository_impl.dart';
import 'package:pscommunitymobileapp/features/family/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/home/controllers/home_controller.dart';
import 'package:pscommunitymobileapp/features/home/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/features/marriage/repositories/marriage_repository_impl.dart';
import 'package:pscommunitymobileapp/features/marriage/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/repositories/member_repository_impl.dart';
import 'package:pscommunitymobileapp/features/member/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/features/occupation/repositories/occupation_repository_impl.dart';
import 'package:pscommunitymobileapp/features/occupation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/payment/repositories/payment_repository_impl.dart';
import 'package:pscommunitymobileapp/features/payment/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/repositories/samaj_repository_impl.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/bank_account_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/splash/controllers/splash_controller.dart';
import 'package:pscommunitymobileapp/features/support/controller/support_controller.dart';

class DI {
  static Future<void> bootstrap() async {
    try {
      await Future(() async {
        AppEnvironment.init();
        final secureStorage = SecureStorageService();
        Get.put(secureStorage, permanent: true);
        final tokenManager = TokenManager(secureStorage);
        await tokenManager.bootstrap();

        AppColors.updateColors(
          tokenManager.authState.value.primaryColor,
          tokenManager.authState.value.secondaryColor,
        );

        Get.put(tokenManager, permanent: true);

        final connectivityPlugin = Connectivity();
        final connectivity = ConnectivityService(
          connectivity: connectivityPlugin,
        );
        Get.put(connectivity, permanent: true);

        final authState = AuthState(tokenManager);
        Get.put(authState, permanent: true);

        final sessionManager = SessionManager(authState);
        Get.put(sessionManager, permanent: true);

        final apiClient = ApiClient(
          tokenManager: tokenManager,
          connectivity: connectivity,
          onAuthFailure: authState.logoutAndRedirect,
        );
        Get.put(apiClient, permanent: true);

        final localization = LocalizationService(secureStorage);
        await localization.bootstrap();
        Get.put(localization, permanent: true);
        final authRepository = AuthRepositoryImpl(apiClient, tokenManager);
        final loginUseCase = LoginUseCase(authRepository);
        Get.put(loginUseCase, permanent: true);
        Get.lazyPut(() => ResetPasswordController(authRepository), fenix: true);
        Get.lazyPut(() => SplashController(), fenix: true);
        final memberRepository = MemberRepositoryImpl(apiClient);
        final familyRepository = FamilyRepositoryImpl(apiClient);
        Get.lazyPut(() => FamilyController(familyRepository), fenix: true);
        Get.lazyPut(
          () => FindMemberController(memberRepository, familyRepository),
          fenix: true,
        );
        final marriageRepository = MarriageRepositoryImpl(apiClient);
        Get.lazyPut(
          () => MarriageController(
            marriageRepository,
            memberRepository,
            familyRepository,
          ),
          fenix: true,
        );
        final committeeRepository = CommitteeRepositoryImpl(apiClient);
        Get.lazyPut(
          () => CommitteeController(committeeRepository),
          fenix: true,
        );
        final occupationRepository = OccupationRepositoryImpl(apiClient);
        Get.lazyPut(
          () => OccupationController(occupationRepository, familyRepository),
          fenix: true,
        );
        final PaymentRepository paymentRepository = PaymentRepositoryImpl(
          apiClient,
        );
        Get.lazyPut(() => PaymentController(paymentRepository), fenix: true);
        final businessRepository = BusinessRepositoryImpl(apiClient);
        Get.lazyPut(() => BusinessController(businessRepository), fenix: true);
        final samajRepository = SamajRepositoryImpl(apiClient);
        final samajController = Get.put(
          SamajController(samajRepository),
          permanent: true,
        );

        Get.lazyPut(() => BankAccountController(samajRepository), fenix: true);
        Get.lazyPut(() => SupportController(apiClient), fenix: true);
        Get.lazyPut(() => HomeController(), fenix: true);
        Get.lazyPut(() => ShareController(apiClient), fenix: true);
        Get.lazyPut(() => EventsController(), fenix: true);
        final pushNotificationService = PushNotificationService(apiClient);
        await pushNotificationService.init();
        Get.put(pushNotificationService, permanent: true);

        if (authState.isAuthenticated.value) {
          unawaited(samajController.fetchAll());
        }
      }).timeout(const Duration(seconds: 15));
    } catch (e) {
      rethrow;
    }
  }
}
