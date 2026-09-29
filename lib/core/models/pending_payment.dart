/// A Razorpay payment that has been captured but not yet confirmed by our
/// backend. Persisted before calling verify so it can be retried after a
/// network error or after the OS kills the app during checkout.
class PendingPayment {
  const PendingPayment({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.amount,
    required this.paymentTypeId,
    required this.paymentCategoryId,
    required this.isRecurring,
    this.adminPaymentRequestId,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      razorpayOrderId: json['razorpayOrderId'] as String? ?? '',
      razorpayPaymentId: json['razorpayPaymentId'] as String? ?? '',
      razorpaySignature: json['razorpaySignature'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentTypeId: json['paymentTypeId'] as int? ?? 0,
      paymentCategoryId: json['paymentCategoryId'] as int? ?? 0,
      isRecurring: json['isRecurring'] as bool? ?? false,
      adminPaymentRequestId: json['adminPaymentRequestId'] as int?,
    );
  }

  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final double amount;
  final int paymentTypeId;
  final int paymentCategoryId;
  final bool isRecurring;
  final int? adminPaymentRequestId;

  Map<String, dynamic> toJson() => {
    'razorpayOrderId': razorpayOrderId,
    'razorpayPaymentId': razorpayPaymentId,
    'razorpaySignature': razorpaySignature,
    'amount': amount,
    'paymentTypeId': paymentTypeId,
    'paymentCategoryId': paymentCategoryId,
    'isRecurring': isRecurring,
    'adminPaymentRequestId': adminPaymentRequestId,
  };
}

/// Same as [PendingPayment], for event registrations.
class PendingEventPayment {
  const PendingEventPayment({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.eventId,
    required this.memberId,
    required this.guests,
    this.eventCouponId,
  });

  factory PendingEventPayment.fromJson(Map<String, dynamic> json) {
    return PendingEventPayment(
      razorpayOrderId: json['razorpayOrderId'] as String? ?? '',
      razorpayPaymentId: json['razorpayPaymentId'] as String? ?? '',
      razorpaySignature: json['razorpaySignature'] as String? ?? '',
      eventId: json['eventId'] as int? ?? 0,
      memberId: json['memberId'] as int? ?? 0,
      eventCouponId: json['eventCouponId'] as int?,
      guests: (json['guests'] as List<dynamic>? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((g) => Map<String, dynamic>.from(g))
          .toList(),
    );
  }

  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final int eventId;
  final int memberId;
  final int? eventCouponId;
  final List<Map<String, dynamic>> guests;

  Map<String, dynamic> toJson() => {
    'razorpayOrderId': razorpayOrderId,
    'razorpayPaymentId': razorpayPaymentId,
    'razorpaySignature': razorpaySignature,
    'eventId': eventId,
    'memberId': memberId,
    'eventCouponId': eventCouponId,
    'guests': guests,
  };
}
