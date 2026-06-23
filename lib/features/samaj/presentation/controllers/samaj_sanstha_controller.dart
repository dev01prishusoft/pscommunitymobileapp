
import 'package:pscommunitymobileapp/core/utils/pagination_mixin.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

class SamajSansthaController extends PaginationMixin<SamajSanstha> {
  SamajSansthaController(this._repository);
  final SamajRepository _repository;

  @override
  void onInit() {
    super.onInit();
    refreshData(showInitialLoading: true);
  }

  @override
  Future<Result<List<SamajSanstha>>> fetchPage(int page, CancelToken? cancelToken) async {
    final result = await _repository.getSamajSansthas(
      pageNumber: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
    
    if (result is Success<PaginatedResponse<SamajSanstha>>) {
      return Success(result.data.data);
    } else {
      return Error((result as Error).failure);
    }
  }
}
