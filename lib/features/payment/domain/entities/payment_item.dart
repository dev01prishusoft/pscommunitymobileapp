enum PaymentStatus {
  success,
  pending,
  failed,
  unknown;

  static PaymentStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'success':
      case 'completed':
        return PaymentStatus.success;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.unknown:
        return 'Unknown';
    }
  }
}

class PaymentItem {
  PaymentItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
    required this.type,
    this.notes = '',
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['paymentId'] as int? ?? json['id'] as int? ?? 0,
      title: json['memberName'] as String? ?? json['title'] as String? ?? '',
      amount: json['amount']?.toString() ?? '',
      date: json['paymentDate'] as String? ?? json['date'] as String? ?? '',
      method: json['paymentModeName'] as String? ?? json['method'] as String? ?? '',
      status: PaymentStatus.fromString(json['paymentStatusName'] as String? ?? json['status'] as String? ?? ''),
      type: json['paymentTypeName'] as String? ?? json['type'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
  final int id;
  final String title;
  final String amount;
  final String date;
  final String method;
  final PaymentStatus status;
  final String type;
  final String notes;
}
