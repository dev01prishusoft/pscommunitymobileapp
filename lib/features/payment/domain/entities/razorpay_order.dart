class RazorpayOrder {
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String keyId;

  RazorpayOrder({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.keyId,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      orderId: json['orderId'] as String? ?? '',
      amountInPaise: json['amountInPaise'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String? ?? '',
    );
  }
}
