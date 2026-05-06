import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<PaymentItem>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const PaymentItem(
        title: 'Annual Membership 2024',
        amount: '₹ 1,000',
        date: '15 Jan 2024',
        method: 'UPI',
        status: 'Success',
        type: 'membership',
      ),
      const PaymentItem(
        title: 'Donation - Education Fund',
        amount: '₹ 5,000',
        date: '20 Dec 2023',
        method: 'Net Banking',
        status: 'Success',
        type: 'donation',
      ),
      const PaymentItem(
        title: 'Temple Maintenance',
        amount: '₹ 500',
        date: '05 Nov 2023',
        method: 'UPI',
        status: 'Success',
        type: 'temple',
      ),
    ];
  }
}
