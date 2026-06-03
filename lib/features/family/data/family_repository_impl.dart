import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member_address.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Member> getMemberDetails(int memberId) async {
    AppLogger.d('Member Detail Request for ID: $memberId');
    final response = await _apiClient.getParsed<Member>(
      '${ApiEndpoints.memberDetail}/$memberId',
      fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
    );
    return response.dataOrNull!.data!;
  }

  @override
  Future<List<MemberAddress>> getMemberAddresses(int memberId) async {
    AppLogger.d('Member Address Request for ID: $memberId');
    final response = await _apiClient.getParsed<List<MemberAddress>>(
      '${ApiEndpoints.memberAddress}/$memberId',
      fromJsonT: (json) => (json as List)
          .map((e) => MemberAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.dataOrNull?.data ?? [];
  }

  @override
  Future<List<DropdownItem>> getStates() async {
    final response = await _apiClient.getParsed<List<DropdownItem>>(
      ApiEndpoints.stateDropdown,
      fromJsonT: (json) => _parseDropdownListData(json),
    );
    return response.dataOrNull?.data ?? [];
  }

  @override
  Future<List<DropdownItem>> getDistricts(int stateId) async {
    final response = await _apiClient.getParsed<List<DropdownItem>>(
      ApiEndpoints.districtDropdown,
      queryParameters: {'stateId': stateId},
      fromJsonT: (json) => _parseDropdownListData(json),
    );
    return response.dataOrNull?.data ?? [];
  }

  @override
  Future<List<DropdownItem>> getTalukas(int districtId) async {
    final response = await _apiClient.getParsed<List<DropdownItem>>(
      ApiEndpoints.talukaDropdown,
      queryParameters: {'districtId': districtId},
      fromJsonT: (json) => _parseDropdownListData(json),
    );
    return response.dataOrNull?.data ?? [];
  }

  @override
  Future<List<DropdownItem>> getAreas(int talukaId) async {
    final response = await _apiClient.getParsed<List<DropdownItem>>(
      ApiEndpoints.areaDropdown,
      queryParameters: {'talukaId': talukaId},
      fromJsonT: (json) => _parseDropdownListData(json),
    );
    return response.dataOrNull?.data ?? [];
  }

  List<DropdownItem> _parseDropdownListData(dynamic data) {
    if (data is Map<String, dynamic>) {
      data = data['data'] ?? data['items'] ?? [];
    }
    if (data is! List) return [];
    return data
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FamilyArea>> getFamilyAreas({
    int? stateId,
    int? districtId,
    int? talukaId,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      if (stateId != null && stateId > 0) 'stateId': stateId,
      if (districtId != null && districtId > 0) 'districtId': districtId,
      if (talukaId != null && talukaId > 0) 'talukaId': talukaId,
      'pageNumber': pageNo,
      'pageSize': pageSize,
    };

    AppLogger.d('Family Areas Request: $queryParameters');

    try {
      final response = await _apiClient.getPaginated<FamilyArea>(
        ApiEndpoints.familyAreas,
        queryParameters: queryParameters,
        listKey: 'data',
        fromJsonT: (json) => FamilyArea.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data ?? [];
    } on Exception catch (e) {
      AppLogger.e('GetFamilyAreaForSamaj Error', e);
      rethrow;
    }
  }

  @override
  Future<List<Family>> getFamiliesByArea(
    int areaId, {
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'areaId': areaId,
      'pageNumber': pageNo,
      'pageSize': pageSize,
    };

    AppLogger.d('Families By Area Request: $queryParameters');

    try {
      final response = await _apiClient.getPaginated<Family>(
        ApiEndpoints.getFamiliesByArea,
        queryParameters: queryParameters,
        listKey: 'families',
        fromJsonT: (json) => Family.fromJson(json as Map<String, dynamic>),
      );
      return response.dataOrNull?.data ?? [];
    } on Exception catch (e) {
      AppLogger.e('GetFamiliesByArea Error', e);
      rethrow;
    }
  }
}
