import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/features/auth/data/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:pscommunitymobileapp/features/member/data/member_repository_impl.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/features/marriage/data/marriage_repository_impl.dart';
import 'package:pscommunitymobileapp/features/marriage/presentation/controllers/marriage_controller.dart';
import 'package:pscommunitymobileapp/features/committee/data/committee_repository_impl.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/occupation/data/occupation_repository_impl.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/data/payment_repository_impl.dart';
import 'package:pscommunitymobileapp/features/payment/data/mocks/mock_payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/family/data/family_repository_impl.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/business/data/business_repository_impl.dart';
import 'package:pscommunitymobileapp/features/business/presentation/controllers/business_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/data/repositories/samaj_repository_impl.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/profile_form_controller.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/home_controller.dart';
import 'package:pscommunitymobileapp/features/home/presentation/controllers/share_controller.dart';

class DI {
  static Future<void> bootstrap() async {
    try {
      // 1. Config
      AppEnvironment.init();

    // 2. Storage
    final secureStorage = SecureStorageService();
    Get.put(secureStorage, permanent: true);

    // 3. Services
    final tokenManager = TokenManager(secureStorage);
    await tokenManager.bootstrap();
    Get.put(tokenManager, permanent: true);

    final connectivityPlugin = Connectivity();
    final connectivity = ConnectivityService(connectivity: connectivityPlugin);
    Get.put(connectivity, permanent: true);

    final authState = AuthState(tokenManager);
    Get.put(authState, permanent: true);

    // 4. Localization
    final localization = LocalizationService(secureStorage);
    await localization.bootstrap();
    Get.put(localization, permanent: true);

    // 5. Network
    final apiClient = ApiClient(
      tokenManager: tokenManager,
      connectivity: connectivity,
      onAuthFailure: authState.logoutAndRedirect,
    );
    Get.put(apiClient, permanent: true);

    // 6. Auth Feature
    final authRepository = AuthRepositoryImpl(apiClient);
    final loginUseCase = LoginUseCase(authRepository);
    Get.put(loginUseCase, permanent: true);
    // LoginController is instantiated in LoginPage to prevent Duplicate GlobalKey errors during transitions
    Get.lazyPut(() => ResetPasswordController(authRepository), fenix: true);

    // 7. Member Feature
    final memberRepository = MemberRepositoryImpl(apiClient);
    Get.lazyPut(() => FindMemberController(memberRepository), fenix: true);

    // 8. Family Feature
    final familyRepository = FamilyRepositoryImpl(apiClient);
    Get.lazyPut(() => FamilyController(familyRepository), fenix: true);

    // 9. Marriage Feature
    final marriageRepository = MarriageRepositoryImpl(apiClient);
    Get.lazyPut(() => MarriageController(marriageRepository, memberRepository, familyRepository), fenix: true);

    // 10. Committee Feature
    final committeeRepository = CommitteeRepositoryImpl(apiClient);
    Get.lazyPut(() => CommitteeController(committeeRepository), fenix: true);

    // 11. Occupation Feature
    final occupationRepository = OccupationRepositoryImpl(apiClient);
    Get.lazyPut(() => OccupationController(occupationRepository), fenix: true);

    // 12. Payment Feature
    final PaymentRepository paymentRepository =
        kDebugMode && AppEnvironment.I.flavor == Flavor.dev
            ? MockPaymentRepository()
            : PaymentRepositoryImpl(apiClient);
    Get.lazyPut(() => PaymentController(paymentRepository), fenix: true);

    // 13. Business Feature
    final businessRepository = BusinessRepositoryImpl(apiClient);
    Get.lazyPut(() => BusinessController(businessRepository), fenix: true);

    // 14. Global Samaj Data
    final samajRepository = SamajRepositoryImpl(apiClient);
    final samajController = Get.put(SamajController(samajRepository), permanent: true);

    // 15. Profile Feature
    // ProfileFormController is instantiated per page in the UI to prevent GlobalKey duplication

    // 16. Home Feature
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ShareController(), fenix: true);

    // Auto-fetch samaj data if already logged in (e.g. app reopen with valid tokens)
    if (authState.isAuthenticated.value) {
      unawaited(samajController.fetchAll());
    }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Bootstrap Failed: $e\n$stackTrace');
      }
      // Depending on the app's architecture, we might want to throw or show a fatal error UI
      rethrow;
    }
  }
}
