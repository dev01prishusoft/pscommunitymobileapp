class PaymentRequest {
  final int id;
  final String title;
  final double amount;
  final String amountFormatted;
  final String dueDate;
  final String dueDateRaw;
  final int paymentTypeId;
  final int paymentCategoryId;
  final String icon;

  PaymentRequest({
    required this.id,
    required this.title,
    required this.amount,
    required this.amountFormatted,
    required this.dueDate,
    required this.dueDateRaw,
    required this.paymentTypeId,
    required this.paymentCategoryId,
    required this.icon,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountFormatted: json['amountFormatted'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      dueDateRaw: json['dueDateRaw'] as String? ?? '',
      paymentTypeId: json['paymentTypeId'] as int? ?? 0,
      paymentCategoryId: json['paymentCategoryId'] as int? ?? 0,
      icon: json['icon'] as String? ?? 'general',
    );
  }
}
