import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class WorkInfoController extends GetxController {
  final defaultOccupationTypes = ['Agriculture', 'Business', 'Job', 'Profession'];
  
  final occupationTypeList = <String>[].obs;
  final workStateList = <String>[].obs;
  final workDistrictList = <String>[].obs;
  final workTalukaList = <String>[].obs;
  final workAreaList = <String>[].obs;

  final workStateIdMap = <String, int>{};
  final workDistrictIdMap = <String, int>{};
  final workTalukaIdMap = <String, int>{};

  final globalDistrictIdMap = <String, int>{};
  final globalTalukaIdMap = <String, int>{};

  final addressDistrictCache = <String, RxList<String>>{};
  final addressTalukaCache = <String, RxList<String>>{};
  final addressAreaCache = <String, RxList<String>>{};

  final occupationType = 'Agriculture'.obs;
  final occupation = ''.obs;
  final jobPosition = ''.obs;
  final otherJobPosition = ''.obs;
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

  late final TextEditingController companyNameCtrl;
  late final TextEditingController businessNameCtrl;
  late final TextEditingController workAddressLine1Ctrl;
  late final TextEditingController workAddressLine2Ctrl;
  late final TextEditingController jobPositionCtrl;

  @override
  void onInit() {
    super.onInit();
    companyNameCtrl = TextEditingController();
    businessNameCtrl = TextEditingController();
    workAddressLine1Ctrl = TextEditingController();
    workAddressLine2Ctrl = TextEditingController();
    jobPositionCtrl = TextEditingController();

    companyNameCtrl.addListener(() => companyName.value = companyNameCtrl.text);
    businessNameCtrl.addListener(() => businessName.value = businessNameCtrl.text);
    workAddressLine1Ctrl.addListener(() => workAddressLine1.value = workAddressLine1Ctrl.text);
    workAddressLine2Ctrl.addListener(() => workAddressLine2.value = workAddressLine2Ctrl.text);
    jobPositionCtrl.addListener(() => jobPosition.value = jobPositionCtrl.text);

    ever(workState, (_) {
      fetchDistricts().then((_) => _ensureSelectionValue(workDistrict, workDistrictList));
    });
    ever(workDistrict, (_) {
      fetchTalukas().then((_) => _ensureSelectionValue(workTaluka, workTalukaList));
    });
    ever(workTaluka, (_) {
      fetchAreas().then((_) => _ensureSelectionValue(workArea, workAreaList));
    });
  }

  @override
  void onClose() {
    companyNameCtrl.dispose();
    businessNameCtrl.dispose();
    workAddressLine1Ctrl.dispose();
    workAddressLine2Ctrl.dispose();
    jobPositionCtrl.dispose();
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

    companyNameCtrl.text = companyName.value;
    businessNameCtrl.text = businessName.value;
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (list.isNotEmpty && !list.contains(selected.value)) {
      selected.value = list.first;
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
      await fetchDropdown('/area/dropdown?talukaId=$talukaId', workAreaList, []);
    } else {
      workAreaList.clear();
      workArea.value = '';
    }
  }

  RxList<String> getAddressDistricts(String stateName) {
    if (stateName.isEmpty) return <String>[].obs;
    if (addressDistrictCache.containsKey(stateName)) {
      return addressDistrictCache[stateName]!;
    }
    final list = <String>[].obs;
    addressDistrictCache[stateName] = list;
    final stateId = workStateIdMap[stateName];
    if (stateId != null) {
      fetchDropdown('/district/dropdown?stateId=$stateId', list, [], idMap: globalDistrictIdMap);
    }
    return list;
  }

  RxList<String> getAddressTalukas(String districtName) {
    if (districtName.isEmpty) return <String>[].obs;
    if (addressTalukaCache.containsKey(districtName)) {
      return addressTalukaCache[districtName]!;
    }
    final list = <String>[].obs;
    addressTalukaCache[districtName] = list;
    final districtId = globalDistrictIdMap[districtName] ?? workDistrictIdMap[districtName];
    if (districtId != null) {
      fetchDropdown('/taluka/dropdown?districtId=$districtId', list, [], idMap: globalTalukaIdMap);
    }
    return list;
  }

  RxList<String> getAddressAreas(String talukaName) {
    if (talukaName.isEmpty) return <String>[].obs;
    if (addressAreaCache.containsKey(talukaName)) {
      return addressAreaCache[talukaName]!;
    }
    final list = <String>[].obs;
    addressAreaCache[talukaName] = list;
    final talukaId = globalTalukaIdMap[talukaName] ?? workTalukaIdMap[talukaName];
    if (talukaId != null) {
      fetchDropdown('/area/dropdown?talukaId=$talukaId', list, []);
    }
    return list;
  }

  Future<void> fetchDropdown(
    String path,
    RxList<String> targetList,
    List<String> fallbacks,
    {Map<String, int>? idMap}
  ) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1$path');
      if (response.data != null) {
        final json = response.data as Map<String, dynamic>;
        if (json['succeeded'] == true) {
          final rawData = json['data'];
          List<dynamic> list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map<String, dynamic>) {
            list = (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ?? [];
          }
          final items = list
              .map((e) {
                final map = e as Map<String, dynamic>;
                String text = '';
                final textKeys = ['text', 'Text', 'name', 'Name', 'value', 'Value', 'stateName', 'districtName', 'talukaName', 'areaName'];
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

                if (text.isNotEmpty && idMap != null) {
                  final idKeys = ['id', 'Id', 'value', 'Value', 'stateId', 'districtId', 'talukaId', 'areaId'];
                  for (final key in idKeys) {
                    if (map.containsKey(key) && map[key] != null) {
                      final id = int.tryParse(map[key].toString());
                      if (id != null) {
                        idMap[text] = id;
                        break;
                      }
                    }
                  }
                }
                return text;
              })
              .where((s) => s.isNotEmpty)
              .toList();

          if (items.isNotEmpty) {
            targetList.assignAll(items);
            return;
          }
        }
      }
    } catch (e) {
      // Ignore error
    }
    targetList.assignAll(fallbacks);
  }
}
