import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

abstract class BusinessRepository {
  Future<Result<List<BusinessCategory>>> getCategories();
}
