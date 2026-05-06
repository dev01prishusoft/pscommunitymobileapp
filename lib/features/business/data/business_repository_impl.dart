import 'package:pscommunitymobileapp/features/business/domain/repositories/business_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  BusinessRepositoryImpl(this._apiClient);

  @override
  Future<List<BusinessCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const BusinessCategory(title: 'IT & Software', iconKey: 'computer'),
      const BusinessCategory(title: 'Manufacturing', iconKey: 'settings'),
      const BusinessCategory(title: 'Retail & Shop', iconKey: 'shopping_bag'),
      const BusinessCategory(title: 'Real Estate', iconKey: 'home_work'),
      const BusinessCategory(title: 'Agriculture', iconKey: 'agriculture'),
      const BusinessCategory(title: 'Medical & Health', iconKey: 'medical_services'),
      const BusinessCategory(title: 'Education', iconKey: 'school'),
      const BusinessCategory(title: 'Finance', iconKey: 'account_balance'),
    ];
  }
}
