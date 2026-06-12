import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/auth/session_manager.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/auth/data/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:pscommunitymobileapp/features/business/data/business_repository_impl.dart';
import 'package:pscommunitymobileapp/features/business/presentation/controllers/business_controller.dart';
import 'package:pscommunitymobileapp/features/committee/data/committee_repository_impl.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/family/data/family_repository_impl.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/home_controller.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/share_controller.dart';
import 'package:pscommunitymobileapp/features/marriage/data/marriage_repository_impl.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/member/data/member_repository_impl.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/features/occupation/data/occupation_repository_impl.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/payment/data/payment_repository_impl.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/data/repositories/samaj_repository_impl.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/bank_account_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
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
        final memberRepository = MemberRepositoryImpl(apiClient);
        Get.lazyPut(() => FindMemberController(memberRepository), fenix: true);
        final familyRepository = FamilyRepositoryImpl(apiClient);
        Get.lazyPut(() => FamilyController(familyRepository), fenix: true);
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
        Get.lazyPut(() => CommitteeController(committeeRepository), fenix: true);
        final occupationRepository = OccupationRepositoryImpl(apiClient);
        Get.lazyPut(
          () => OccupationController(occupationRepository),
          fenix: true,
        );
        final PaymentRepository paymentRepository = PaymentRepositoryImpl(apiClient);
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
        if (authState.isAuthenticated.value) {
          unawaited(samajController.fetchAll());
        }
      }).timeout(const Duration(seconds: 15));
    } catch (e, stack) {
      AppLogger.e('Fatal crash during dependency injection bootstrap', e, stack);
      rethrow;
    }
  }
}
