import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/library_category_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';

abstract class LibraryRepository {

  Future<Result<List<LibraryCategoryData>>> getCategories({
    String? search,
    CancelToken? cancelToken,
  });

  Future<Result<PaginatedResponse<LibraryItemData>>> getCategoryItems({
    required int categoryId,
    int page = 1,
    int pageSize = 20,
    String? search,
    CancelToken? cancelToken,
  });

  Future<Result<LibraryItemDetailsData>> getItemDetails(
    dynamic id, {
    CancelToken? cancelToken,
  });
}

