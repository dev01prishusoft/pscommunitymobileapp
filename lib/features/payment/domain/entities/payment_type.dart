class PaymentType {
  final int id;
  final String name;

  PaymentType({required this.id, required this.name});

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
