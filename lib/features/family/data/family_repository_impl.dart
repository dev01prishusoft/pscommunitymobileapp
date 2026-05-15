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
    return _parseDropdownList(response.data);
  }

  @override
  Future<List<DropdownItem>> getDistricts(int stateId) async {
    final response = await _apiClient.get(
      ApiEndpoints.districtDropdown,
      queryParameters: {'stateId': stateId},
    );
    return _parseDropdownList(response.data);
  }

  @override
  Future<List<DropdownItem>> getTalukas(int districtId) async {
    final response = await _apiClient.get(
      ApiEndpoints.talukaDropdown,
      queryParameters: {'districtId': districtId},
    );
    return _parseDropdownList(response.data);
  }

  List<DropdownItem> _parseDropdownList(dynamic responseData) {
    if (responseData == null) return [];
    final json = responseData as Map<String, dynamic>;
    if (json['succeeded'] != true) return [];
    
    var data = json['data'];
    // Handle double wrapping: { data: { data: [...] } } or { data: [...] }
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
  Future<List<Family>> getFamiliesByArea(int areaId, {int pageNo = 1, int pageSize = 20}) async {
    final queryParameters = <String, dynamic>{
      'areaId': areaId,
      'pageNumber': pageNo,
      'pageSize': pageSize,
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
