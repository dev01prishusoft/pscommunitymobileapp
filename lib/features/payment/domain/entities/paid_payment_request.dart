class PaidPaymentRequest {
  PaidPaymentRequest({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.title,
    required this.amount,
    required this.amountFormatted,
    required this.paidDate,
    required this.receiptId,
    required this.status,
    this.recurringType = '',
  });

  factory PaidPaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaidPaymentRequest(
      id: json['id'] as int? ?? 0,
      memberId: json['memberId'] as int? ?? 0,
      memberName: json['memberName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountFormatted: json['amountFormatted'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      receiptId: json['receiptId'] as int? ?? 0,
      status: json['status'] as String? ?? json['paymentStatus'] as String? ?? 'Paid',
      recurringType: json['recurringType'] as String? ?? '',
    );
  }
  final int id;
  final int memberId;
  final String memberName;
  final String title;
  final double amount;
  final String amountFormatted;
  final String paidDate;
  final int receiptId;
  final String status;
  final String recurringType;
}
