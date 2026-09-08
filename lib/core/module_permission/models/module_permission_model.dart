import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';

/// Representation of a Samaj module permission as returned by:
/// - POST /api/v1/auth/member-login
/// - POST /api/v1/auth/member-refresh-token
/// - POST /api/v1/auth/login
/// - POST /api/v1/auth/refresh-token
/// - GET  /api/v1/samaj-module/my-modules
class ModulePermissionModel {
  const ModulePermissionModel({
    required this.code,
    this.moduleId,
    this.name,
    this.description,
    this.sortOrder,
    this.isEnabled = false,
    this.isAccessible = false,
    this.validFrom,
    this.validTo,
    this.remarks,
    this.samajModuleId,
  });

  final int? moduleId;
  final String code;
  final String? name;
  final String? description;
  final int? sortOrder;
  final bool isEnabled;

  /// Primary flag to show/hide menus and UI features.
  /// If true, the module is purchased and currently active.
  final bool isAccessible;

  final DateTime? validFrom;
  final DateTime? validTo;
  final String? remarks;
  final int? samajModuleId;

  /// Returns the corresponding strongly-typed [AppModule] if recognized.
  AppModule? get appModule => AppModule.fromCode(code);

  /// Factory constructor to parse JSON safely with robust type casting.
  factory ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    return ModulePermissionModel(
      moduleId: json['moduleId'] is int
          ? json['moduleId'] as int
          : int.tryParse(json['moduleId']?.toString() ?? ''),
      code: (json['code']?.toString() ?? '').trim().toUpperCase(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse(json['sortOrder']?.toString() ?? ''),
      isEnabled: json['isEnabled'] == true || json['isEnabled']?.toString().toLowerCase() == 'true',
      isAccessible: json['isAccessible'] == true || json['isAccessible']?.toString().toLowerCase() == 'true',
      validFrom: _parseDateTime(json['validFrom']),
      validTo: _parseDateTime(json['validTo']),
      remarks: json['remarks']?.toString(),
      samajModuleId: json['samajModuleId'] is int
          ? json['samajModuleId'] as int
          : int.tryParse(json['samajModuleId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'code': code,
      'name': name,
      'description': description,
      'sortOrder': sortOrder,
      'isEnabled': isEnabled,
      'isAccessible': isAccessible,
      'validFrom': validFrom?.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
      'remarks': remarks,
      'samajModuleId': samajModuleId,
    };
  }

  ModulePermissionModel copyWith({
    int? moduleId,
    String? code,
    String? name,
    String? description,
    int? sortOrder,
    bool? isEnabled,
    bool? isAccessible,
    DateTime? validFrom,
    DateTime? validTo,
    String? remarks,
    int? samajModuleId,
  }) {
    return ModulePermissionModel(
      moduleId: moduleId ?? this.moduleId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      isAccessible: isAccessible ?? this.isAccessible,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      remarks: remarks ?? this.remarks,
      samajModuleId: samajModuleId ?? this.samajModuleId,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModulePermissionModel &&
        other.code == code &&
        other.isAccessible == isAccessible &&
        other.isEnabled == isEnabled &&
        other.moduleId == moduleId &&
        other.samajModuleId == samajModuleId;
  }

  @override
  int get hashCode => Object.hash(code, isAccessible, isEnabled, moduleId, samajModuleId);

  @override
  String toString() => 'ModulePermissionModel(code: $code, isAccessible: $isAccessible, isEnabled: $isEnabled)';
}
