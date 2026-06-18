enum PaymentStatus {
  success,
  pending,
  failed,
  unknown;

  static PaymentStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'paid':
        return PaymentStatus.success;
      case 'pending':
      case 'unpaid':
      case 'initiated':
        return PaymentStatus.pending;
      case 'failed':
      case 'cancelled':
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
    required this.rawStatus,
    required this.type,
    this.notes = '',
    this.isRecurring = false,
    this.planName = '',
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['paymentId'] as int? ?? json['id'] as int? ?? 0,
      title: json['memberName'] as String? ?? json['title'] as String? ?? '',
      amount: json['amount']?.toString() ?? '',
      date: json['paymentDate'] as String? ?? json['date'] as String? ?? '',
      method: json['paymentModeName'] as String? ?? json['method'] as String? ?? '',
      status: PaymentStatus.fromString(json['paymentStatusName'] as String? ?? json['status'] as String? ?? ''),
      rawStatus: json['paymentStatusName'] as String? ?? json['status'] as String? ?? 'Unknown',
      type: json['paymentTypeName'] as String? ?? json['type'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isRecurring: json['isRecurring'] as bool? ?? false,
      planName: json['planName'] as String? ?? '',
    );
  }
  final int id;
  final String title;
  final String amount;
  final String date;
  final String method;
  final PaymentStatus status;
  final String rawStatus;
  final String type;
  final String notes;
  final bool isRecurring;
  final String planName;
}
