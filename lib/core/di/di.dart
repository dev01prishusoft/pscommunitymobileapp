import 'package:flutter/foundation.dart';
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
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';
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

class DI {
  static Future<void> bootstrap() async {
    // 1. Config
    AppEnvironment.init();

    // 2. Storage
    final secureStorage = SecureStorageService();
    Get.put(secureStorage, permanent: true);

    // 3. Services
    final tokenManager = TokenManager(secureStorage);
    await tokenManager.bootstrap();
    Get.put(tokenManager, permanent: true);

    final connectivity = ConnectivityService();
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
      onAuthFailure: () => authState.logout(),
    );
    Get.put(apiClient, permanent: true);
    
    // 6. Auth Feature
    final authRepository = AuthRepositoryImpl(apiClient);
    final loginUseCase = LoginUseCase(authRepository);
    Get.put(LoginController(loginUseCase, tokenManager), permanent: true);
    Get.put(ResetPasswordController(authRepository), permanent: true);

    // 7. Member Feature
    final memberRepository = MemberRepositoryImpl(apiClient);
    Get.put(FindMemberController(memberRepository), permanent: true);

    // 8. Marriage Feature
    final marriageRepository = MarriageRepositoryImpl(apiClient);
    Get.put(MarriageController(marriageRepository, memberRepository), permanent: true);

    // 9. Committee Feature
    final committeeRepository = CommitteeRepositoryImpl(apiClient);
    Get.put(CommitteeController(committeeRepository), permanent: true);

    // 10. Occupation Feature
    final occupationRepository = OccupationRepositoryImpl(apiClient);
    Get.put(OccupationController(occupationRepository), permanent: true);

    // 11. Payment Feature
    final PaymentRepository paymentRepository = 
        kDebugMode && AppEnvironment.I.flavor == Flavor.dev
            ? MockPaymentRepository()
            : PaymentRepositoryImpl(apiClient);
    Get.put(PaymentController(paymentRepository), permanent: true);

    // 12. Family Feature
    final familyRepository = FamilyRepositoryImpl(apiClient);
    Get.put(FamilyController(familyRepository), permanent: true);

    // 13. Business Feature
    final businessRepository = BusinessRepositoryImpl(apiClient);
    Get.put(BusinessController(businessRepository), permanent: true);

    // 14. Global Samaj Detail
    final samajRepository = SamajRepositoryImpl(apiClient);
    final samajController = Get.put(SamajController(samajRepository), permanent: true);
    
    // Auto-fetch if already logged in
    if (authState.isAuthenticated.value) {
      samajController.fetchSamajDetail();
    }
  }
}
