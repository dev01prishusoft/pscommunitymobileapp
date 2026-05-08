import 'package:pscommunitymobileapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/payment/domain/entities/payment_item.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<PaymentItem>> getPaymentHistory() async {
    final response = await _apiClient.get(ApiEndpoints.payments);
    final json = response.data as Map<String, dynamic>;
    
    if (json['succeeded'] != true) {
      return [];
    }
    
    final list = json['data'] as List? ?? [];
    return list.map((e) => PaymentItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
