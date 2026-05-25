class DropdownItem {
  DropdownItem({required this.id, required this.text});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    int? id;
    String? text;
    final idKeys = [
      'id',
      'Id',
      'value',
      'Value',
      'stateId',
      'districtId',
      'talukaId',
      'areaId',
      'occupationId',
      'StateId',
      'DistrictId',
      'TalukaId',
      'AreaId',
    ];
    for (final key in idKeys) {
      if (json.containsKey(key) && json[key] != null) {
        id = int.tryParse(json[key].toString());
        if (id != null) break;
      }
    }
    final textKeys = [
      'text',
      'Text',
      'name',
      'Name',
      'stateName',
      'districtName',
      'talukaName',
      'areaName',
      'occupationName',
      'StateName',
      'DistrictName',
      'TalukaName',
      'AreaName',
    ];
    for (final key in textKeys) {
      if (json.containsKey(key) && json[key] != null) {
        text = json[key].toString();
        if (text.isNotEmpty) break;
      }
    }
    if (id == null) {
      for (final entry in json.entries) {
        if (entry.key.toLowerCase().contains('id') ||
            entry.key.toLowerCase().contains('value')) {
          id = int.tryParse(entry.value.toString());
          if (id != null) break;
        }
      }
    }

    if (text == null || text.isEmpty) {
      for (final entry in json.entries) {
        if (entry.key.toLowerCase().contains('name') ||
            entry.key.toLowerCase().contains('text') ||
            entry.key.toLowerCase().contains('title')) {
          text = entry.value.toString();
          if (text.isNotEmpty) break;
        }
      }
    }

    return DropdownItem(id: id ?? 0, text: text ?? '');
  }
  final int id;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}
