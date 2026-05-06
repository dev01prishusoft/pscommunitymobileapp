import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<PaymentItem>> getPaymentHistory() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const [
      PaymentItem(
        title: 'Membership Fee - Annual',
        amount: '₹2,000',
        date: '15 Mar 2025',
        method: 'UPI',
        status: 'Success',
        icon: Icons.assignment,
        iconColor: Color(0xFF1E5BB6),
      ),
      PaymentItem(
        title: 'Donation - General',
        amount: '₹500',
        date: '10 Feb 2025',
        method: 'Card',
        status: 'Success',
        icon: Icons.volunteer_activism,
        iconColor: Color(0xFF1B8D5E),
      ),
      PaymentItem(
        title: 'Temple Fund - Annual',
        amount: '₹1,000',
        date: '05 Jan 2025',
        method: 'Cash',
        status: 'Success',
        icon: Icons.account_balance,
        iconColor: Color(0xFF002B5B),
      ),
      PaymentItem(
        title: 'Membership Fee - Life Member',
        amount: '₹5,000',
        date: '10 Dec 2024',
        method: 'Cheque',
        status: 'Success',
        icon: Icons.badge,
        iconColor: Color(0xFFE67E22),
      ),
    ];
  }
}
