class PaymentMode {
  PaymentMode({required this.id, required this.name});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['id'] as int? ?? json['paymentModeId'] as int? ?? 0,
      name: json['name'] as String? ?? json['paymentModeName'] as String? ?? '',
    );
  }
  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
