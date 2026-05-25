class PaymentCategory {
  PaymentCategory({
    required this.id,
    required this.name,
    required this.defaultAmount,
  });

  factory PaymentCategory.fromJson(Map<String, dynamic> json) {
    return PaymentCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      defaultAmount: (json['defaultAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
  final int id;
  final String name;
  final double defaultAmount;
}
