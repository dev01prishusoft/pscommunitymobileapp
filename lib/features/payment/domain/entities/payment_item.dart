class PaymentItem {
  final String title;
  final String amount;
  final String date;
  final String method;
  final String status;
  final String type; // used to determine icon and color in UI

  const PaymentItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
    required this.type,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      title: json['title'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      date: json['date'] as String? ?? '',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
