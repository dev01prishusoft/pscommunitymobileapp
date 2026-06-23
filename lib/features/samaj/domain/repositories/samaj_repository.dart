import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

abstract class SamajRepository {
  Future<Samaj?> getSamajDetail();
  Future<List<SamajBankDetais>> getBankAccountDetails();
  Future<Result<PaginatedResponse<SamajSanstha>>> getSamajSansthas({
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  });
}
