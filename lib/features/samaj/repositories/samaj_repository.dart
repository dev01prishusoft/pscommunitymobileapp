import 'package:pscommunitymobileapp/core/models/samaj.dart';
import 'package:pscommunitymobileapp/core/models/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/core/models/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
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
