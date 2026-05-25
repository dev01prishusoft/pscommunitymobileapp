class PaidPaymentRequest {
  PaidPaymentRequest({
    required this.id,
    required this.title,
    required this.amountFormatted,
    required this.paidDate,
    required this.receiptId,
  });

  factory PaidPaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaidPaymentRequest(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      amountFormatted: json['amountFormatted'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      receiptId: json['receiptId'] as int? ?? 0,
    );
  }
  final int id;
  final String title;
  final String amountFormatted;
  final String paidDate;
  final int receiptId;
}
