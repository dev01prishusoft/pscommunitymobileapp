import 'payment_request.dart';
import 'paid_payment_request.dart';

class PaymentDashboard {
  PaymentDashboard({
    required this.totalDue,
    required this.pendingPayments,
    required this.paidPayments,
  });

  factory PaymentDashboard.fromJson(Map<String, dynamic> json) {
    final pending =
        (json['pendingPayments'] as List?)
            ?.map((e) => PaymentRequest.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final paid =
        (json['paidPayments'] as List?)
            ?.map((e) => PaidPaymentRequest.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaymentDashboard(
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: pending,
      paidPayments: paid,
    );
  }
  final double totalDue;
  final List<PaymentRequest> pendingPayments;
  final List<PaidPaymentRequest> paidPayments;
}
