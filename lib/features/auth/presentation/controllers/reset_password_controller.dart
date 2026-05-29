import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/utils/form_state_mixin.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';

class ResetPasswordController extends GetxController with FormStateMixin {
  ResetPasswordController(this._repo);
  final AuthRepository _repo;

  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> resetPassword(
    String mobile,
    String oldPwd,
    String newPassword,
  ) async {
    await submitThrottled(() async {
      final result = await _repo.memberUpdatePassword(
        mobileNo: mobile,
        oldPassword: oldPwd,
        newPassword: newPassword,
      );
      if (result is Error<void>) {
        formError.value = result.failure.message;
        throw result.failure;
      } else {
        if (Get.isRegistered<TokenManager>()) {
          await Get.find<TokenManager>().markPasswordReset();
        }
      }
    });
  }
}
