class PaymentCategory {
  PaymentCategory({
    required this.id,
    required this.name,
    required this.defaultAmount,
    required this.minAmount,
    required this.maxAmount,
    this.isRecurring = false,
    this.isAmountFixed = false,
  });

  factory PaymentCategory.fromJson(Map<String, dynamic> json) {
    return PaymentCategory(
      id: json['id'] as int? ?? json['paymentCategoryId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      defaultAmount: (json['defaultAmount'] as num?)?.toDouble() ?? 0.0,
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 0.0,
      // 0 means no upper limit — do NOT default to 50000 which would wrongly cap free-entry plans
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 0.0,
      isRecurring: json['isRecurring'] as bool? ?? false,
      isAmountFixed: json['isAmountFixed'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final double defaultAmount;
  final double minAmount;
  final double maxAmount;
  final bool isRecurring;
  final bool isAmountFixed;
}
