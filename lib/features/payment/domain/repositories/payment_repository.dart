import 'package:flutter/material.dart';

class PaymentItem {
  final String title;
  final String amount;
  final String date;
  final String method;
  final String status;
  final IconData icon;
  final Color iconColor;

  const PaymentItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
    required this.icon,
    required this.iconColor,
  });
}

abstract class PaymentRepository {
  Future<List<PaymentItem>> getPaymentHistory();
}
