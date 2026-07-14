import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class BankAccountController extends GetxController {
  BankAccountController(this._repository);
  final SamajRepository _repository;

  final bankAccountDetails = <SamajBankDetais>[].obs;

  bool _isFetchingBankDetails = false;

  final RxBool isLoading = false.obs;
  final RxnString bankdetailsError = RxnString();

  Future<void> fetchBankAccountDetail() async {
    if (_isFetchingBankDetails) return;
    _isFetchingBankDetails = true;

    isLoading.value = true;
    bankdetailsError.value = null;

    try {
      final detail = await _repository.getBankAccountDetails();

      if (detail.isNotEmpty) {
        bankAccountDetails.assignAll(detail);
      }
    } catch (e) {
      bankdetailsError.value = e.toString();
    } finally {
      isLoading.value = false;
      _isFetchingBankDetails = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    bankdetailsError.value = null;
    _isFetchingBankDetails = false;
  }
}
