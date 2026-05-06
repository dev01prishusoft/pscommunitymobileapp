import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';

abstract class PaymentRepository {
  Future<List<PaymentItem>> getPaymentHistory();
}
