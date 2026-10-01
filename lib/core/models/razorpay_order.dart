class RazorpayOrder {
  RazorpayOrder({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.keyId,
    this.subscriptionId,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amountInPaise'] ?? json['amount'];
    final int amountPaise = rawAmount is num
        ? rawAmount.toInt()
        : (int.tryParse(rawAmount?.toString() ?? '') ?? 0);
    return RazorpayOrder(
      orderId: json['orderId'] as String? ?? '',
      amountInPaise: amountPaise,
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String? ?? '',
      subscriptionId: json['subscriptionId'] as String?,
    );
  }
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String keyId;
  final String? subscriptionId;
}
