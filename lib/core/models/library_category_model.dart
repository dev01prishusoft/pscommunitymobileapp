import 'package:flutter/material.dart';

class LibraryCategoriesModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  List<LibraryCategoryData>? data;

  LibraryCategoriesModel({
    this.statusCode,
    this.succeeded,
    this.message,
    this.data,
  });

  LibraryCategoriesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'] is int
        ? json['statusCode'] as int
        : int.tryParse(json['statusCode']?.toString() ?? '');
    succeeded = json['succeeded'] as bool?;
    message = json['message'] as String?;
    if (json['data'] != null) {
      data = <LibraryCategoryData>[];
      if (json['data'] is List) {
        for (final v in json['data']) {
          if (v is Map<String, dynamic>) {
            data!.add(LibraryCategoryData.fromJson(v));
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['statusCode'] = statusCode;
    jsonMap['succeeded'] = succeeded;
    jsonMap['message'] = message;
    if (data != null) {
      jsonMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return jsonMap;
  }
}

class LibraryCategoryData {
  int? libraryCategoryId;
  String? _name;
  String? _description;
  String? iconName;
  String? iconColor;
  String? bgColor;
  int? sortOrder;
  int? _itemCount;

  LibraryCategoryData({
    this.libraryCategoryId,
    String? name,
    String? description,
    this.iconName,
    this.iconColor,
    this.bgColor,
    this.sortOrder,
    int? itemCount,
  })  : _name = name,
        _description = description,
        _itemCount = itemCount;

  String get name => _name ?? '';
  set name(String val) => _name = val;

  String get description => _description ?? '';
  set description(String val) => _description = val;

  int get itemCount => _itemCount ?? 0;
  set itemCount(int val) => _itemCount = val;

  LibraryCategoryData.fromJson(Map<String, dynamic> json) {
    libraryCategoryId = json['libraryCategoryId'] is int
        ? json['libraryCategoryId'] as int
        : int.tryParse(json['libraryCategoryId']?.toString() ?? '');
    _name = json['name']?.toString();
    _description = json['description']?.toString();
    iconName = json['iconName']?.toString();
    iconColor = json['iconColor']?.toString();
    bgColor = json['bgColor']?.toString();
    sortOrder = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : int.tryParse(json['sortOrder']?.toString() ?? '');
    _itemCount = json['itemCount'] is int
        ? json['itemCount'] as int
        : int.tryParse(json['itemCount']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['libraryCategoryId'] = libraryCategoryId;
    jsonMap['name'] = _name;
    jsonMap['description'] = _description;
    jsonMap['iconName'] = iconName;
    jsonMap['iconColor'] = iconColor;
    jsonMap['bgColor'] = bgColor;
    jsonMap['sortOrder'] = sortOrder;
    jsonMap['itemCount'] = _itemCount;
    return jsonMap;
  }

  // Helper getters for UI compatibility
  int get id => libraryCategoryId ?? 0;
  String get iconType => iconName ?? '';

  Color get backgroundColor => _parseHexColor(bgColor, const Color(0xFFF1F5F9));
  Color get iconColorResolved =>
      _parseHexColor(iconColor, const Color(0xFF475569));

  static Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    var cleaned = hexString.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    }
    try {
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

typedef Data = LibraryCategoryData;
typedef LibraryCategoryModel = LibraryCategoryData;
