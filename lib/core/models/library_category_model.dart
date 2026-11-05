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

class LibraryCategoryData implements Comparable<LibraryCategoryData> {
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
    _name = (json['name'] ?? json['Name'] ?? json['categoryName'] ?? json['CategoryName'])?.toString();
    _description = (json['description'] ?? json['Description'])?.toString();
    final dynamic rawIconName =
        json['iconName'] ?? json['IconName'] ?? json['icon_name'];
    iconName = rawIconName?.toString();
    final dynamic rawIconColor =
        json['iconColor'] ?? json['IconColor'] ?? json['icon_color'];
    iconColor = rawIconColor?.toString();
    final dynamic rawBgColor =
        json['bgColor'] ?? json['BgColor'] ?? json['bg_color'];
    bgColor = rawBgColor?.toString();
    final dynamic rawSortOrder =
        json['sortOrder'] ?? json['SortOrder'] ?? json['sort_order'];
    sortOrder = rawSortOrder is int
        ? rawSortOrder
        : (rawSortOrder is num
            ? rawSortOrder.toInt()
            : int.tryParse(rawSortOrder?.toString() ?? ''));
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

  Color get iconColorResolved =>
      _parseHexColor(iconColor, const Color(0xFF475569));

  Color get backgroundColor {
    if (iconColor != null && iconColor!.trim().isNotEmpty) {
      final parsed = _parseHexColor(iconColor, const Color(0xFF475569));
      return Color.alphaBlend(parsed.withValues(alpha: 0.12), Colors.white);
    }
    if (bgColor != null && bgColor!.trim().isNotEmpty) {
      return _parseHexColor(bgColor, const Color(0xFFF1F5F9));
    }
    return const Color(0xFFF1F5F9);
  }

  static Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null) return fallback;
    var cleaned = hexString.trim();
    if (cleaned.isEmpty) return fallback;
    if (cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1).trim();
    }
    if (cleaned.startsWith('0x') || cleaned.startsWith('0X')) {
      cleaned = cleaned.substring(2).trim();
    }
    if (cleaned.length == 3) {
      cleaned =
          '${cleaned[0]}${cleaned[0]}${cleaned[1]}${cleaned[1]}${cleaned[2]}${cleaned[2]}';
    }
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    }
    if (cleaned.length == 8) {
      try {
        return Color(int.parse(cleaned, radix: 16));
      } catch (_) {
        return fallback;
      }
    }
    return fallback;
  }

  static int compareBySortOrder(LibraryCategoryData a, LibraryCategoryData b) {
    final orderA = a.sortOrder;
    final orderB = b.sortOrder;

    if (orderA != null && orderB != null) {
      final cmp = orderA.compareTo(orderB);
      if (cmp != 0) return cmp;
    } else if (orderA != null) {
      return -1;
    } else if (orderB != null) {
      return 1;
    }

    final titleA = a.name.trim().toLowerCase();
    final titleB = b.name.trim().toLowerCase();
    final titleCmp = titleA.compareTo(titleB);
    if (titleCmp != 0) return titleCmp;

    final idA = a.libraryCategoryId ?? 0;
    final idB = b.libraryCategoryId ?? 0;
    return idA.compareTo(idB);
  }

  @override
  int compareTo(LibraryCategoryData other) => compareBySortOrder(this, other);
}

typedef Data = LibraryCategoryData;
typedef LibraryCategoryModel = LibraryCategoryData;
