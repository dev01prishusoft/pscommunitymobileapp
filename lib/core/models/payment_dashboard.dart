import 'paid_payment_request.dart';

class PaymentDashboard {
  PaymentDashboard({
    required this.totalDue,
    required this.paidPayments,
  });

  factory PaymentDashboard.fromJson(Map<String, dynamic> json) {
    final paid =
        (json['data'] as List?)
            ?.map((e) => PaidPaymentRequest.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaymentDashboard(
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      paidPayments: paid,
    );
  }
  final double totalDue;
  final List<PaidPaymentRequest> paidPayments;
}
