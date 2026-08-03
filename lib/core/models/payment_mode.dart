class PaymentMode {
  PaymentMode({required this.id, required this.name});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['paymentModeId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
  final int id;
  final String name;
}
