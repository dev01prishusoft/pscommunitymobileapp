class PaymentCategory {
  PaymentCategory({
    required this.id,
    required this.name,
    required this.defaultAmount,
    required this.minAmount,
    required this.maxAmount,
  });

  factory PaymentCategory.fromJson(Map<String, dynamic> json) {
    return PaymentCategory(
      id: json['id'] as int? ?? json['paymentCategoryId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      defaultAmount: (json['defaultAmount'] as num?)?.toDouble() ?? 0.0,
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 100.0,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 50000.0,
    );
  }
  final int id;
  final String name;
  final double defaultAmount;
  final double minAmount;
  final double maxAmount;
}
