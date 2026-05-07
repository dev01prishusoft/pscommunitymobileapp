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
    final response = await _apiClient.get('${ApiEndpoints.memberDetail}/$memberId');
    final json = response.data as Map<String, dynamic>;
    AppLogger.d('Member Detail Response: $json');
    
    if (json['succeeded'] != true) {
      throw Exception(json['message'] ?? 'Failed to load member details');
    }
    
    final data = json['data'] as Map<String, dynamic>;
    return Member.fromJson(data);
  }

  @override
  Future<List<MemberAddress>> getMemberAddresses(int memberId) async {
    AppLogger.d('Member Address Request for ID: $memberId');
    final response = await _apiClient.get('${ApiEndpoints.memberAddress}/$memberId');
    final json = response.data as Map<String, dynamic>;
    AppLogger.d('Member Address Response: $json');
    
    if (json['succeeded'] != true) return [];
    
    final data = json['data'] as List? ?? [];
    return data.map((e) => MemberAddress.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DropdownItem>> getStates() async {
    final response = await _apiClient.get(ApiEndpoints.stateDropdown);
    final json = response.data as Map<String, dynamic>;
    AppLogger.d('States Response: $json');
    if (json['succeeded'] != true) return [];
    final data = json['data'] as List? ?? [];
    return data
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DropdownItem>> getDistricts(int stateId) async {
    AppLogger.d('Districts Request for stateId: $stateId');
    final response = await _apiClient.get(
      ApiEndpoints.districtDropdown,
      queryParameters: {'stateId': stateId},
    );
    final json = response.data as Map<String, dynamic>;
    AppLogger.d('Districts Response: $json');
    if (json['succeeded'] != true) return [];
    final data = json['data'] as List? ?? [];
    return data
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DropdownItem>> getTalukas(int districtId) async {
    AppLogger.d('Talukas Request for districtId: $districtId');
    final response = await _apiClient.get(
      ApiEndpoints.talukaDropdown,
      queryParameters: {'districtId': districtId},
    );
    final json = response.data as Map<String, dynamic>;
    AppLogger.d('Talukas Response: $json');
    if (json['succeeded'] != true) return [];
    final data = json['data'] as List? ?? [];
    return data
        .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FamilyArea>> getFamilyAreas({
    int? stateId,
    int? districtId,
    int? talukaId,
  }) async {
    final queryParameters = <String, dynamic>{
      if (stateId != null && stateId > 0) 'StateId': stateId,
      if (districtId != null && districtId > 0) 'DistrictId': districtId,
      if (talukaId != null && talukaId > 0) 'TalukaId': talukaId,
      'PageNumber': 1,
      'PageSize': 100,
    };

    AppLogger.d('Family Areas Request: $queryParameters');
    
    try {
      final response = await _apiClient.get(
        ApiEndpoints.familyAreas,
        queryParameters: queryParameters,
      );

      final json = response.data as Map<String, dynamic>;
      AppLogger.d('Family Areas Response: $json');

      if (json['succeeded'] != true) return [];
      
      // The API response is double-wrapped: { data: { data: [...] } }
      final outerData = json['data'] as Map<String, dynamic>? ?? {};
      final innerData = outerData['data'] as List? ?? [];
      
      return innerData.map((e) => FamilyArea.fromJson(e as Map<String, dynamic>)).toList();
    } on Exception catch (e) {
      // Log the full response if possible to see validation errors
      AppLogger.e('GetFamilyAreaForSamaj Error', e);
      rethrow;
    }
  }

  @override
  Future<List<Family>> getFamiliesByArea(int areaId) async {
    final queryParameters = <String, dynamic>{
      'areaId': areaId,
      'pageNumber': 1,
      'pageSize': 20,
    };

    AppLogger.d('Families By Area Request: $queryParameters');
    
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFamiliesByArea,
        queryParameters: queryParameters,
      );

      final json = response.data as Map<String, dynamic>;
      AppLogger.d('Families By Area Response: $json');

      if (json['succeeded'] != true) return [];
      
      final dataObj = json['data'];
      List<dynamic> items = [];
      
      if (dataObj is Map<String, dynamic>) {
        // Try 'families' then 'data' as fallback
        items = (dataObj['families'] ?? dataObj['data']) as List? ?? [];
      } else if (dataObj is List) {
        items = dataObj;
      }
      
      return items.map((e) => Family.fromJson(e as Map<String, dynamic>)).toList();
    } on Exception catch (e) {
      AppLogger.e('GetFamiliesByArea Error', e);
      rethrow;
    }
  }
}
