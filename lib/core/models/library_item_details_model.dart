import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';

class LibraryItemsDetailsModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  LibraryItemDetailsData? data;

  LibraryItemsDetailsModel({
    this.statusCode,
    this.succeeded,
    this.message,
    this.data,
  });

  LibraryItemsDetailsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'] is int
        ? json['statusCode'] as int
        : int.tryParse(json['statusCode']?.toString() ?? '');
    succeeded = json['succeeded'] as bool?;
    message = json['message'] as String?;
    data = json['data'] != null
        ? LibraryItemDetailsData.fromJson(json['data'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['statusCode'] = statusCode;
    jsonMap['succeeded'] = succeeded;
    jsonMap['message'] = message;
    if (data != null) {
      jsonMap['data'] = data!.toJson();
    }
    return jsonMap;
  }
}

class LibraryItemDetailsData {
  int? libraryItemId;
  int? libraryCategoryId;
  String? categoryName;
  String? categoryIconName;
  String? categoryIconColor;
  int? libraryContentTypeId;
  String? contentTypeCode;
  String? contentTypeName;
  String? contentTypeBadge;
  String? contentTypeIconName;
  String? contentTypeIconColor;
  String? allowedExtensions;
  String? title;
  String? shortDescription;
  String? description;
  dynamic bodyText;
  String? publishedOn;
  dynamic thumbnailPath;
  dynamic durationSeconds;
  dynamic pageCount;
  int? fileSizeBytes;
  bool? canDownload;
  bool? canShare;
  bool? canOpenInBrowser;
  int? sortOrder;
  List<LibraryItemFile>? files;

  String get formattedDate => formatDateString(publishedOn, fallback: '');

  LibraryItemDetailsData({
    this.libraryItemId,
    this.libraryCategoryId,
    this.categoryName,
    this.categoryIconName,
    this.categoryIconColor,
    this.libraryContentTypeId,
    this.contentTypeCode,
    this.contentTypeName,
    this.contentTypeBadge,
    this.contentTypeIconName,
    this.contentTypeIconColor,
    this.allowedExtensions,
    this.title,
    this.shortDescription,
    this.description,
    this.bodyText,
    this.publishedOn,
    this.thumbnailPath,
    this.durationSeconds,
    this.pageCount,
    this.fileSizeBytes,
    this.canDownload,
    this.canShare,
    this.canOpenInBrowser,
    this.sortOrder,
    this.files,
  });

  static bool? _parseBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  LibraryItemDetailsData.fromJson(Map<String, dynamic> json) {
    libraryItemId = json['libraryItemId'] is int
        ? json['libraryItemId'] as int
        : int.tryParse(json['libraryItemId']?.toString() ?? '');
    libraryCategoryId = json['libraryCategoryId'] is int
        ? json['libraryCategoryId'] as int
        : int.tryParse(json['libraryCategoryId']?.toString() ?? '');
    categoryName = json['categoryName']?.toString();
    categoryIconName = json['categoryIconName']?.toString();
    categoryIconColor = json['categoryIconColor']?.toString();
    libraryContentTypeId = json['libraryContentTypeId'] is int
        ? json['libraryContentTypeId'] as int
        : int.tryParse(json['libraryContentTypeId']?.toString() ?? '');
    contentTypeCode = json['contentTypeCode']?.toString();
    contentTypeName = json['contentTypeName']?.toString();
    contentTypeBadge = json['contentTypeBadge']?.toString();
    contentTypeIconName = json['contentTypeIconName']?.toString();
    contentTypeIconColor = json['contentTypeIconColor']?.toString();
    allowedExtensions = json['allowedExtensions']?.toString();
    title = json['title']?.toString();
    shortDescription = json['shortDescription']?.toString();
    description = json['description']?.toString();
    bodyText = json['bodyText'];
    publishedOn = json['publishedOn']?.toString();
    thumbnailPath = json['thumbnailPath'];
    durationSeconds = json['durationSeconds'];
    pageCount = json['pageCount'];
    fileSizeBytes = json['fileSizeBytes'] is int
        ? json['fileSizeBytes'] as int
        : int.tryParse(json['fileSizeBytes']?.toString() ?? '');
    canDownload = _parseBool(json['canDownload'] ?? json['CanDownload']);
    canShare = _parseBool(json['canShare'] ?? json['CanShare']);
    canOpenInBrowser = _parseBool(json['canOpenInBrowser'] ??
        json['CanOpenInBrowser'] ??
        json['canOpenInNewTab'] ??
        json['CanOpenInNewTab']);
    sortOrder = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : int.tryParse(json['sortOrder']?.toString() ?? '');
    if (json['files'] != null) {
      files = <LibraryItemFile>[];
      if (json['files'] is List) {
        for (final v in json['files']) {
          if (v is Map<String, dynamic>) {
            files!.add(LibraryItemFile.fromJson(v));
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['libraryItemId'] = libraryItemId;
    jsonMap['libraryCategoryId'] = libraryCategoryId;
    jsonMap['categoryName'] = categoryName;
    jsonMap['categoryIconName'] = categoryIconName;
    jsonMap['categoryIconColor'] = categoryIconColor;
    jsonMap['libraryContentTypeId'] = libraryContentTypeId;
    jsonMap['contentTypeCode'] = contentTypeCode;
    jsonMap['contentTypeName'] = contentTypeName;
    jsonMap['contentTypeBadge'] = contentTypeBadge;
    jsonMap['contentTypeIconName'] = contentTypeIconName;
    jsonMap['contentTypeIconColor'] = contentTypeIconColor;
    jsonMap['allowedExtensions'] = allowedExtensions;
    jsonMap['title'] = title;
    jsonMap['shortDescription'] = shortDescription;
    jsonMap['description'] = description;
    jsonMap['bodyText'] = bodyText;
    jsonMap['publishedOn'] = publishedOn;
    jsonMap['thumbnailPath'] = thumbnailPath;
    jsonMap['durationSeconds'] = durationSeconds;
    jsonMap['pageCount'] = pageCount;
    jsonMap['fileSizeBytes'] = fileSizeBytes;
    jsonMap['canDownload'] = canDownload;
    jsonMap['canShare'] = canShare;
    jsonMap['canOpenInBrowser'] = canOpenInBrowser;
    jsonMap['sortOrder'] = sortOrder;
    if (files != null) {
      jsonMap['files'] = files!.map((v) => v.toJson()).toList();
    }
    return jsonMap;
  }
}

class LibraryItemFile {
  int? libraryItemFileId;
  String? fileName;
  String? filePath;
  dynamic thumbnailPath;
  String? caption;
  dynamic alternativeText;
  String? mimeType;
  int? fileSizeBytes;
  dynamic durationSeconds;
  dynamic pageCount;
  bool? isPrimary;
  int? sortOrder;

  LibraryItemFile({
    this.libraryItemFileId,
    this.fileName,
    this.filePath,
    this.thumbnailPath,
    this.caption,
    this.alternativeText,
    this.mimeType,
    this.fileSizeBytes,
    this.durationSeconds,
    this.pageCount,
    this.isPrimary,
    this.sortOrder,
  });

  LibraryItemFile.fromJson(Map<String, dynamic> json) {
    libraryItemFileId = json['libraryItemFileId'] is int
        ? json['libraryItemFileId'] as int
        : int.tryParse(json['libraryItemFileId']?.toString() ?? '');
    fileName = json['fileName']?.toString();
    filePath = json['filePath']?.toString();
    thumbnailPath = json['thumbnailPath'];
    caption = json['caption']?.toString();
    alternativeText = json['alternativeText'];
    mimeType = json['mimeType']?.toString();
    fileSizeBytes = json['fileSizeBytes'] is int
        ? json['fileSizeBytes'] as int
        : int.tryParse(json['fileSizeBytes']?.toString() ?? '');
    durationSeconds = json['durationSeconds'];
    pageCount = json['pageCount'];
    isPrimary = json['isPrimary'] as bool?;
    sortOrder = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : int.tryParse(json['sortOrder']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['libraryItemFileId'] = libraryItemFileId;
    jsonMap['fileName'] = fileName;
    jsonMap['filePath'] = filePath;
    jsonMap['thumbnailPath'] = thumbnailPath;
    jsonMap['caption'] = caption;
    jsonMap['alternativeText'] = alternativeText;
    jsonMap['mimeType'] = mimeType;
    jsonMap['fileSizeBytes'] = fileSizeBytes;
    jsonMap['durationSeconds'] = durationSeconds;
    jsonMap['pageCount'] = pageCount;
    jsonMap['isPrimary'] = isPrimary;
    jsonMap['sortOrder'] = sortOrder;
    return jsonMap;
  }
}

typedef Data = LibraryItemDetailsData;
typedef Files = LibraryItemFile;

