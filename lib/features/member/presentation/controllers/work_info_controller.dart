import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class WorkInfoController extends GetxController {
  final defaultOccupationTypes = ['Agriculture', 'Business', 'Job', 'Profession'];
  
  final occupationTypeList = <String>[].obs;
  final occupationList = <String>[].obs;
  final jobPositionList = <String>[].obs;

  final workStateList = <String>[].obs;
  final workDistrictList = <String>[].obs;
  final workTalukaList = <String>[].obs;
  final workAreaList = <String>[].obs;

  final occupationTypeIdMap = <String, int>{}.obs;
  final occupationIdMap = <String, int>{}.obs;
  final jobPositionIdMap = <String, int>{}.obs;

  final workStateIdMap = <String, int>{}.obs;
  final workDistrictIdMap = <String, int>{}.obs;
  final workTalukaIdMap = <String, int>{}.obs;
  final workAreaIdMap = <String, int>{}.obs;

  final globalStateIdMap = <String, int>{}.obs;
  final globalDistrictIdMap = <String, int>{}.obs;
  final globalTalukaIdMap = <String, int>{}.obs;
  final globalAreaIdMap = <String, int>{}.obs;

  final addressDistrictCache = <String, RxList<String>>{};
  final addressTalukaCache = <String, RxList<String>>{};
  final addressAreaCache = <String, RxList<String>>{};

  final occupationType = ''.obs;
  final occupation = ''.obs;
  final jobPosition = ''.obs;
  final otherJobPosition = ''.obs;
  final otherJobPositionEnglish = ''.obs;
  final otherOccupation = ''.obs;
  final companyName = ''.obs;
  final businessName = ''.obs;
  final workMonthlyIncome = ''.obs;
  final occupationDescription = ''.obs;
  final workState = ''.obs;
  final workDistrict = ''.obs;
  final workTaluka = ''.obs;
  final workArea = ''.obs;
  final workAddressLine1 = ''.obs;
  final workAddressLine2 = ''.obs;
  final workLandmark = ''.obs;
  final workPincode = ''.obs;

  late final TextEditingController companyNameCtrl;
  late final TextEditingController businessNameCtrl;
  late final TextEditingController workAddressLine1Ctrl;
  late final TextEditingController workAddressLine2Ctrl;
  late final TextEditingController workLandmarkCtrl;
  late final TextEditingController workPincodeCtrl;
  late final TextEditingController jobPositionCtrl;
  late final TextEditingController otherJobPositionCtrl;
  late final TextEditingController otherJobPositionEnglishCtrl;
  late final TextEditingController otherOccupationCtrl;
  late final TextEditingController occupationDescriptionCtrl;

  @override
  void onInit() {
    super.onInit();
    companyNameCtrl = TextEditingController();
    businessNameCtrl = TextEditingController();
    workAddressLine1Ctrl = TextEditingController();
    workAddressLine2Ctrl = TextEditingController();
    workLandmarkCtrl = TextEditingController();
    workPincodeCtrl = TextEditingController();
    jobPositionCtrl = TextEditingController();
    otherJobPositionCtrl = TextEditingController();
    otherJobPositionEnglishCtrl = TextEditingController();
    otherOccupationCtrl = TextEditingController();
    occupationDescriptionCtrl = TextEditingController();

    companyNameCtrl.addListener(() => companyName.value = companyNameCtrl.text);
    businessNameCtrl.addListener(() => businessName.value = businessNameCtrl.text);
    workAddressLine1Ctrl.addListener(() => workAddressLine1.value = workAddressLine1Ctrl.text);
    workAddressLine2Ctrl.addListener(() => workAddressLine2.value = workAddressLine2Ctrl.text);
    workLandmarkCtrl.addListener(() => workLandmark.value = workLandmarkCtrl.text);
    workPincodeCtrl.addListener(() => workPincode.value = workPincodeCtrl.text);
    jobPositionCtrl.addListener(() => jobPosition.value = jobPositionCtrl.text);
    otherJobPositionCtrl.addListener(() => otherJobPosition.value = otherJobPositionCtrl.text);
    otherJobPositionEnglishCtrl.addListener(() => otherJobPositionEnglish.value = otherJobPositionEnglishCtrl.text);
    otherOccupationCtrl.addListener(() => otherOccupation.value = otherOccupationCtrl.text);
    occupationDescriptionCtrl.addListener(() => occupationDescription.value = occupationDescriptionCtrl.text);

    ever(workState, (_) {
      fetchDistricts().then((_) => _ensureSelectionValue(workDistrict, workDistrictList));
    });
    ever(workDistrict, (_) {
      fetchTalukas().then((_) => _ensureSelectionValue(workTaluka, workTalukaList));
    });
    ever(workTaluka, (_) {
      fetchAreas().then((_) => _ensureSelectionValue(workArea, workAreaList));
    });
    ever(occupationType, (_) {
      fetchOccupations().then((_) => _ensureSelectionValue(occupation, occupationList));
    });
  }

  @override
  void onClose() {
    companyNameCtrl.dispose();
    businessNameCtrl.dispose();
    workAddressLine1Ctrl.dispose();
    workAddressLine2Ctrl.dispose();
    workLandmarkCtrl.dispose();
    workPincodeCtrl.dispose();
    jobPositionCtrl.dispose();
    otherJobPositionCtrl.dispose();
    otherJobPositionEnglishCtrl.dispose();
    otherOccupationCtrl.dispose();
    occupationDescriptionCtrl.dispose();
    super.onClose();
  }

  void loadFromMember(Member m) {
    occupationType.value = m.occupationTypeName ?? '';
    occupation.value = m.occupationName ?? '';
    jobPosition.value = m.jobPositionName ?? '';
    otherJobPosition.value = m.otherJobPosition ?? '';
    otherOccupation.value = m.otherOccupation ?? '';
    companyName.value = m.companyName ?? '';
    businessName.value = m.businessName ?? '';
    occupationDescription.value = m.occupationDescription ?? '';
    workState.value = m.occupationStateName ?? '';
    workDistrict.value = m.occupationDistrictName ?? '';
    workTaluka.value = m.occupationTalukaName ?? '';
    workArea.value = m.occupationAreaName ?? '';
    workAddressLine1.value = m.occupationAddressLine1 ?? '';
    workAddressLine2.value = m.occupationAddressLine2 ?? '';
    workLandmark.value = m.occupationLandmark ?? '';
    workPincode.value = m.occupationPincode ?? '';

    companyNameCtrl.text = companyName.value;
    businessNameCtrl.text = businessName.value;
    workAddressLine1Ctrl.text = workAddressLine1.value;
    workAddressLine2Ctrl.text = workAddressLine2.value;
    workLandmarkCtrl.text = workLandmark.value;
    workPincodeCtrl.text = workPincode.value;
    otherJobPositionCtrl.text = otherJobPosition.value;
    otherJobPositionEnglishCtrl.text = otherJobPositionEnglish.value;
    otherOccupationCtrl.text = otherOccupation.value;
    occupationDescriptionCtrl.text = occupationDescription.value;
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (selected.value.isNotEmpty && !list.contains(selected.value)) {
      if (list.isEmpty) return; 
      final query = selected.value.replaceAll(' ', '').toLowerCase();
      
      String? match;
      for (final item in list) {
        if (item.replaceAll(' ', '').toLowerCase() == query) {
          match = item;
          break;
        }
      }
      
      if (match != null) {
        selected.value = match;
      } else {
        selected.value = '';
      }
    }
  }

  Future<void> fetchDistricts() async {
    final stateId = workStateIdMap[workState.value];
    if (stateId != null) {
      await fetchDropdown('/district/dropdown?stateId=$stateId', workDistrictList, [], idMap: workDistrictIdMap);
    } else {
      workDistrictList.clear();
      workDistrictIdMap.clear();
      workDistrict.value = '';
    }
  }

  Future<void> fetchTalukas() async {
    final districtId = workDistrictIdMap[workDistrict.value];
    if (districtId != null) {
      await fetchDropdown('/taluka/dropdown?districtId=$districtId', workTalukaList, [], idMap: workTalukaIdMap);
    } else {
      workTalukaList.clear();
      workTalukaIdMap.clear();
      workTaluka.value = '';
    }
  }

  Future<void> fetchAreas() async {
    final talukaId = workTalukaIdMap[workTaluka.value];
    if (talukaId != null) {
      await fetchDropdown('/Area/dropdown?talukaId=$talukaId', workAreaList, [], idMap: workAreaIdMap);
    } else {
      workAreaList.clear();
      workAreaIdMap.clear();
      workArea.value = '';
    }
  }

  Future<void> fetchOccupations() async {
    final occupationTypeId = occupationTypeIdMap[occupationType.value];
    if (occupationTypeId != null) {
      await fetchDropdown('/Occupation/mobile/dropdown?occupationTypeId=$occupationTypeId', occupationList, [], idMap: occupationIdMap);
    } else {
      occupationList.clear();
      occupationIdMap.clear();
      occupation.value = '';
    }
  }
  void markStateFetched(String stateName) => _fetchedStatesForDistricts.add(stateName);
  void markDistrictFetched(String districtName) => _fetchedDistrictsForTalukas.add(districtName);
  void markTalukaFetched(String talukaName) => _fetchedTalukasForAreas.add(talukaName);

  void renameState(String oldName, String newName) {
    if (oldName == newName) return;
    if (_fetchedStatesForDistricts.remove(oldName)) _fetchedStatesForDistricts.add(newName);
    if (addressDistrictCache.containsKey(oldName)) {
      addressDistrictCache[newName] = addressDistrictCache.remove(oldName)!;
    }
  }

  void renameDistrict(String oldName, String newName) {
    if (oldName == newName) return;
    if (_fetchedDistrictsForTalukas.remove(oldName)) _fetchedDistrictsForTalukas.add(newName);
    if (addressTalukaCache.containsKey(oldName)) {
      addressTalukaCache[newName] = addressTalukaCache.remove(oldName)!;
    }
  }

  void renameTaluka(String oldName, String newName) {
    if (oldName == newName) return;
    if (_fetchedTalukasForAreas.remove(oldName)) _fetchedTalukasForAreas.add(newName);
    if (addressAreaCache.containsKey(oldName)) {
      addressAreaCache[newName] = addressAreaCache.remove(oldName)!;
    }
  }

  final _fetchedStatesForDistricts = <String>{};
  RxList<String> getAddressDistricts(String stateName) {
    if (stateName.isEmpty) return <String>[].obs;
    if (!addressDistrictCache.containsKey(stateName)) {
      addressDistrictCache[stateName] = <String>[].obs;
    }
    final list = addressDistrictCache[stateName]!;
    if (!_fetchedStatesForDistricts.contains(stateName)) {
      _fetchedStatesForDistricts.add(stateName);
      final stateId = globalStateIdMap[stateName] ?? workStateIdMap[stateName];
      if (stateId != null) {
        fetchDropdown('/district/dropdown?stateId=$stateId', list, [], idMap: globalDistrictIdMap, clearMap: false);
      }
    }
    return list;
  }

  Future<RxList<String>> getAddressDistrictsAsync(String stateName) async {
    if (stateName.isEmpty) return <String>[].obs;
    if (!addressDistrictCache.containsKey(stateName)) {
      addressDistrictCache[stateName] = <String>[].obs;
    }
    final list = addressDistrictCache[stateName]!;
    if (!_fetchedStatesForDistricts.contains(stateName)) {
      _fetchedStatesForDistricts.add(stateName);
      final stateId = globalStateIdMap[stateName] ?? workStateIdMap[stateName];
      if (stateId != null) {
        await fetchDropdown('/district/dropdown?stateId=$stateId', list, [], idMap: globalDistrictIdMap, clearMap: false);
      }
    }
    return list;
  }

  final _fetchedDistrictsForTalukas = <String>{};
  RxList<String> getAddressTalukas(String districtName) {
    if (districtName.isEmpty) return <String>[].obs;
    if (!addressTalukaCache.containsKey(districtName)) {
      addressTalukaCache[districtName] = <String>[].obs;
    }
    final list = addressTalukaCache[districtName]!;
    if (!_fetchedDistrictsForTalukas.contains(districtName)) {
      _fetchedDistrictsForTalukas.add(districtName);
      final districtId = globalDistrictIdMap[districtName] ?? workDistrictIdMap[districtName];
      if (districtId != null) {
        fetchDropdown('/taluka/dropdown?districtId=$districtId', list, [], idMap: globalTalukaIdMap, clearMap: false);
      }
    }
    return list;
  }

  Future<RxList<String>> getAddressTalukasAsync(String districtName) async {
    if (districtName.isEmpty) return <String>[].obs;
    if (!addressTalukaCache.containsKey(districtName)) {
      addressTalukaCache[districtName] = <String>[].obs;
    }
    final list = addressTalukaCache[districtName]!;
    if (!_fetchedDistrictsForTalukas.contains(districtName)) {
      _fetchedDistrictsForTalukas.add(districtName);
      final districtId = globalDistrictIdMap[districtName] ?? workDistrictIdMap[districtName];
      if (districtId != null) {
        await fetchDropdown('/taluka/dropdown?districtId=$districtId', list, [], idMap: globalTalukaIdMap, clearMap: false);
      }
    }
    return list;
  }

  final _fetchedTalukasForAreas = <String>{};
  RxList<String> getAddressAreas(String talukaName) {
    if (talukaName.isEmpty) return <String>[].obs;
    if (!addressAreaCache.containsKey(talukaName)) {
      addressAreaCache[talukaName] = <String>[].obs;
    }
    final list = addressAreaCache[talukaName]!;
    if (!_fetchedTalukasForAreas.contains(talukaName)) {
      _fetchedTalukasForAreas.add(talukaName);
      final talukaId = globalTalukaIdMap[talukaName] ?? workTalukaIdMap[talukaName];
      if (talukaId != null) {
        fetchDropdown('/Area/dropdown?talukaId=$talukaId', list, [], idMap: globalAreaIdMap, clearMap: false);
      }
    }
    return list;
  }

  Future<RxList<String>> getAddressAreasAsync(String talukaName) async {
    if (talukaName.isEmpty) return <String>[].obs;
    if (!addressAreaCache.containsKey(talukaName)) {
      addressAreaCache[talukaName] = <String>[].obs;
    }
    final list = addressAreaCache[talukaName]!;
    if (!_fetchedTalukasForAreas.contains(talukaName)) {
      _fetchedTalukasForAreas.add(talukaName);
      final talukaId = globalTalukaIdMap[talukaName] ?? workTalukaIdMap[talukaName];
      if (talukaId != null) {
        await fetchDropdown('/Area/dropdown?talukaId=$talukaId', list, [], idMap: globalAreaIdMap, clearMap: false);
      }
    }
    return list;
  }

  Future<void> fetchDropdown(
    String path,
    RxList<String> targetList,
    List<String> fallbacks,
    {Map<String, int>? idMap, bool clearMap = true}
  ) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1$path');
      if (response.data != null) {
        final json = response.data as Map<String, dynamic>;
        if (json['succeeded'] == true) {
          if (path.toLowerCase().contains('taluka') || path.toLowerCase().contains('area')) {
          }
          final rawData = json['data'];
          List<dynamic> list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map<String, dynamic>) {
            list = (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ?? [];
          }
          targetList.clear();
          if (idMap != null && clearMap) idMap.clear();

          final seenIds = <int>{};
          final items = <String>[];

          for (final e in list) {
                final map = e as Map<String, dynamic>;
                String text = '';
                final textKeys = [
                  'text', 'Text', 'name', 'Name', 'value', 'Value',
                  'bloodGroupName', 'BloodGroupName', 'genderName', 'GenderName', 'maritalStatusName', 'MaritalStatusName', 'signName', 'SignName',
                  'relationTypeName', 'RelationTypeName', 'occupationTypeName', 'OccupationTypeName', 'jobPositionName', 'JobPositionName', 
                  'educationName', 'EducationName', 'EducationalQualificationName', 'gotraName', 'GotraName',
                  'stateName', 'StateName', 'districtName', 'DistrictName', 'talukaName', 'TalukaName', 'areaName', 'AreaName'
                ];
                for (final key in textKeys) {
                  if (map.containsKey(key) && map[key] != null) {
                    text = map[key].toString().trim();
                    break;
                  }
                }
                if (text.isEmpty) {
                  for (final entry in map.entries) {
                    if (!entry.key.toLowerCase().contains('id')) {
                      text = entry.value.toString().trim();
                      break;
                    }
                  }
                }

                int? foundId;
                if (text.isNotEmpty) {
                  final idKeys = [
                    'id', 'Id', 'value', 'Value', 
                    'bloodGroupId', 'BloodGroupId', 'genderId', 'GenderId', 'maritalStatusId', 'MaritalStatusId', 'signId', 'SignId',
                    'relationTypeId', 'RelationTypeId', 'occupationTypeId', 'OccupationTypeId', 'jobPositionId', 'JobPositionId',
                    'educationId', 'EducationId', 'EducationalQualificationId', 'gotraId', 'GotraId',
                    'stateId', 'StateId', 'districtId', 'DistrictId', 'talukaId', 'TalukaId', 'areaId', 'AreaId'
                  ];
                  for (final key in idKeys) {
                    if (map.containsKey(key) && map[key] != null) {
                      foundId = int.tryParse(map[key].toString());
                      if (foundId != null) break;
                    }
                  }
                  if (foundId == null) {
                    for (final entry in map.entries) {
                      if (entry.key.toLowerCase().endsWith('id')) {
                        foundId = int.tryParse(entry.value.toString());
                        if (foundId != null) break;
                      }
                    }
                  }
                }

                if (text.isEmpty) continue;
                if (foundId != null && !seenIds.add(foundId)) continue;
                if (items.contains(text)) continue;

                if (idMap != null && foundId != null) {
                  idMap[text] = foundId;
                }
                items.add(text);
          }

          for (final e in items) {
            targetList.add(e);
          }
          String _stripLangSuffix(String s) =>
              s.replaceAll(RegExp(r'\s*\([a-zA-Z]+\)$'), '').trim().toLowerCase();

          for (final f in fallbacks) {
            if (f.isEmpty) continue;
            if (idMap != null) {
              final fId = idMap[f];
              if (fId != null && seenIds.contains(fId)) continue;
            }

            final fNorm = _stripLangSuffix(f);
            final alreadyExists = targetList.any(
              (existing) => _stripLangSuffix(existing) == fNorm,
            );
            if (!alreadyExists) {
              targetList.add(f);
            }
          }
          return;
        }
      }
    } catch (e) {
    }
    targetList.assignAll(fallbacks);
  }
}
