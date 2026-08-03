import 'package:pscommunitymobileapp/core/models/business_category.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';

abstract class BusinessRepository {
  Future<Result<List<BusinessCategory>>> getCategories();
}
