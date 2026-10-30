import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/library_category_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/network/network_exception_mapper.dart';
import 'package:pscommunitymobileapp/features/library/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<List<LibraryCategoryData>>> getCategories({
    String? search,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final result = await _apiClient.getParsed<List<LibraryCategoryData>>(
      ApiEndpoints.categoriesList,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      cancelToken: cancelToken,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) =>
                  LibraryCategoryData.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <LibraryCategoryData>[];
      },
    );

    if (result.isSuccess) {
      return Success(result.dataOrNull?.data ?? <LibraryCategoryData>[]);
    } else {
      return Error(result.failureOrNull!);
    }
  }

  @override
  Future<Result<PaginatedResponse<LibraryItemData>>> getCategoryItems({
    required int categoryId,
    int page = 1,
    int pageSize = 20,
    String? search,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = <String, dynamic>{
      'LibraryCategoryId': categoryId,
      'Page': page,
      'PageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'Search': search.trim(),
    };

    try {
      final response = await _apiClient.get(
        ApiEndpoints.categoryItems,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final model = LibraryItemsModel.fromJson(data);
        final items = model.data ?? <LibraryItemData>[];
        final pagination = model.pagination;

        final paginatedResponse = PaginatedResponse<LibraryItemData>(
          succeeded: model.succeeded ?? true,
          message: model.message,
          data: items,
          pageNumber: pagination?.currentPage ?? page,
          pageSize: pagination?.pageSize ?? pageSize,
          totalRecords: pagination?.totalCount ?? items.length,
          totalPages: pagination?.totalPages ?? (items.isNotEmpty ? 1 : 0),
        );
        return Success(paginatedResponse);
      }

      return Success(
        PaginatedResponse<LibraryItemData>(
          succeeded: true,
          data: <LibraryItemData>[],
          pageNumber: page,
          pageSize: pageSize,
          totalRecords: 0,
          totalPages: 0,
        ),
      );
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<LibraryItemDetailsData>> getItemDetails(
    dynamic id, {
    CancelToken? cancelToken,
  }) async {
    final result = await _apiClient.getParsed<LibraryItemDetailsData>(
      ApiEndpoints.itemDetails(id),
      cancelToken: cancelToken,
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          return LibraryItemDetailsData.fromJson(json);
        }
        return LibraryItemDetailsData();
      },
    );

    if (result.isSuccess) {
      return Success(result.dataOrNull?.data ?? LibraryItemDetailsData());
    } else {
      return Error(result.failureOrNull!);
    }
  }
}

