class PaymentType {
  PaymentType({required this.id, required this.name});

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
