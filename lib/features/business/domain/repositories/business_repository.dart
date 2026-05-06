import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';

abstract class BusinessRepository {
  Future<List<BusinessCategory>> getCategories();
}
