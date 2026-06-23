import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:dio/dio.dart';

class SamajRepositoryImpl implements SamajRepository {
  SamajRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Samaj?> getSamajDetail() async {
    try {
      final response = await _apiClient.getParsed<Samaj>(
        ApiEndpoints.samajDetail,
        fromJsonT: (json) => Samaj.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data;
    } catch (_) {
      return null;
    }
  }

@override
  Future<List<SamajBankDetais>> getBankAccountDetails() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bankDetailsBySamaj);
      final json = response.data as Map<String, dynamic>;
      final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => SamajBankDetais.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Result<PaginatedResponse<SamajSanstha>>> getSamajSansthas({
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.getPaginated<SamajSanstha>(
        ApiEndpoints.samajSansthaList,
        queryParameters: {
          'Page': pageNumber,
          'PageSize': pageSize,
        },
        listKey: 'data',
        fromJsonT: (json) => SamajSanstha.fromJson(json as Map<String, dynamic>),
        cancelToken: cancelToken,
      );

      if (response is Success<PaginatedResponse<SamajSanstha>>) {
        return Success(response.data);
      } else {
        return Error((response as Error).failure);
      }
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
