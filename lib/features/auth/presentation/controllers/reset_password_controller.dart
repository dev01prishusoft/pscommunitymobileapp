import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ResetPasswordController extends GetxController {
  final AuthRepository _repo;
  ResetPasswordController(this._repo);

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  
  void toggleNewPasswordVisibility() => obscureNewPassword.value = !obscureNewPassword.value;
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.value = !obscureConfirmPassword.value;
  
  Future<bool> resetPassword(String mobile, String oldPwd, String newPassword) async {
    isLoading.value = true;
    error.value = null;
    
    try {
      await _repo.memberUpdatePassword(
        mobileNo: mobile,
        oldPassword: oldPwd,
        newPassword: newPassword,
      );
      return true;
    } on Failure catch (f) {
      error.value = f.translationKey.tr;
      return false;
    } catch (e) {
      error.value = LK.somethingWrong.tr;
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
