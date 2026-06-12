import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

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
}
