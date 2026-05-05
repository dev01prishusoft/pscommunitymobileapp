import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repository;

  PaymentController(this._repository);

  final Rx<AppState> state = AppState.loading.obs;
  final RxList<PaymentItem> payments = <PaymentItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    state.value = AppState.loading;
    try {
      final results = await _repository.getPaymentHistory();
      payments.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    } catch (e, stack) {
      AppLogger.e('Failed to load payment history', e, stack);
      state.value = AppState.error;
    }
  }
}
