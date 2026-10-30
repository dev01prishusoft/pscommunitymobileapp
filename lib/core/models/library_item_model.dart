import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';

class LibraryItemsModel {
  int? statusCode;
  bool? succeeded;
  String? message;
  List<LibraryItemData>? data;
  Pagination? pagination;

  LibraryItemsModel({
    this.statusCode,
    this.succeeded,
    this.message,
    this.data,
    this.pagination,
  });

  LibraryItemsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'] is int
        ? json['statusCode'] as int
        : int.tryParse(json['statusCode']?.toString() ?? '');
    succeeded = json['succeeded'] as bool?;
    message = json['message'] as String?;
    if (json['data'] != null) {
      data = <LibraryItemData>[];
      if (json['data'] is List) {
        for (final v in json['data']) {
          if (v is Map<String, dynamic>) {
            data!.add(LibraryItemData.fromJson(v));
          }
        }
      }
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['statusCode'] = statusCode;
    jsonMap['succeeded'] = succeeded;
    jsonMap['message'] = message;
    if (data != null) {
      jsonMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      jsonMap['pagination'] = pagination!.toJson();
    }
    return jsonMap;
  }
}

class LibraryItemData {
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
  String? _title;
  String? _shortDescription;
  String? _description;
  String? publishedOn;
  String? thumbnailPath;
  dynamic durationSeconds;
  dynamic pageCount;
  int? fileSizeBytes;
  String? primaryFilePath;
  int? sortOrder;
  bool? canDownload;
  bool? canShare;
  bool? canOpenInBrowser;

  // Custom UI fields / fallback
  String? _id;
  String? _date;
  String? _type;
  String? _duration;
  String? _downloadUrl;
  String? _shareUrl;
  String? _audioUrl;
  String? _videoUrl;
  String? _fileSize;
  int? _totalPages;
  String? _thumbnail;
  int? totalPhotos;
  String? videoTitle;
  String? about;
  String? contentTitle;
  String? content;
  String? meaning;
  String? author;
  String? language;
  List<RelatedVideoModel> relatedVideos;
  List<PhotoItemModel> photos;

  LibraryItemData({
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
    String? title,
    String? shortDescription,
    String? description,
    this.publishedOn,
    this.thumbnailPath,
    this.durationSeconds,
    this.pageCount,
    this.fileSizeBytes,
    this.primaryFilePath,
    this.sortOrder,
    this.canDownload,
    this.canShare,
    this.canOpenInBrowser,
    String? id,
    String? date,
    String? type,
    String? duration,
    String? downloadUrl,
    String? shareUrl,
    String? audioUrl,
    String? videoUrl,
    String? fileSize,
    int? totalPages,
    String? thumbnail,
    this.totalPhotos,
    this.videoTitle,
    this.about,
    this.contentTitle,
    this.content,
    this.meaning,
    this.author,
    this.language,
    List<RelatedVideoModel>? relatedVideos,
    List<PhotoItemModel>? photos,
  })  : _title = title,
        _shortDescription = shortDescription,
        _description = description,
        _id = id,
        _date = date,
        _type = type,
        _duration = duration,
        _downloadUrl = downloadUrl,
        _shareUrl = shareUrl,
        _audioUrl = audioUrl,
        _videoUrl = videoUrl,
        _fileSize = fileSize,
        _totalPages = totalPages,
        _thumbnail = thumbnail,
        relatedVideos = relatedVideos ?? <RelatedVideoModel>[],
        photos = photos ?? <PhotoItemModel>[];

  String get id => libraryItemId?.toString() ?? _id ?? '';
  set id(String? val) => _id = val;

  String get title => _title ?? '';
  set title(String? val) => _title = val;

  String get description => _shortDescription ?? _description ?? '';
  set description(String? val) {
    _shortDescription = val;
    _description = val;
  }

  String get shortDescription => _shortDescription ?? _description ?? '';
  set shortDescription(String? val) => _shortDescription = val;

  String get date => formatDateString(_date ?? publishedOn, fallback: '');
  set date(String? val) => _date = val;

  String get formattedDate => formatDateString(_date ?? publishedOn, fallback: '');

  String get type => _type ?? contentTypeCode ?? contentTypeName ?? 'FILE';
  set type(String? val) => _type = val;

  String? get downloadUrl => _downloadUrl ?? primaryFilePath;
  set downloadUrl(String? val) => _downloadUrl = val;

  String? get shareUrl => _shareUrl ?? primaryFilePath;
  set shareUrl(String? val) => _shareUrl = val;

  String? get audioUrl => _audioUrl ?? primaryFilePath;
  set audioUrl(String? val) => _audioUrl = val;

  String? get videoUrl => _videoUrl ?? primaryFilePath;
  set videoUrl(String? val) => _videoUrl = val;

  String? get thumbnail => _thumbnail ?? thumbnailPath?.toString();
  set thumbnail(String? val) => _thumbnail = val;

  int? get totalPages {
    if (_totalPages != null) return _totalPages;
    if (pageCount is int) return pageCount as int;
    if (pageCount != null) {
      final parsed = int.tryParse(pageCount.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  set totalPages(int? val) => _totalPages = val;

  String? get duration {
    if (_duration != null && _duration!.isNotEmpty) return _duration;
    final sec = durationSecondsInt;
    if (sec != null && sec > 0) {
      final m = sec ~/ 60;
      final s = sec % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return null;
  }

  set duration(String? val) => _duration = val;

  int? get durationSecondsInt {
    if (durationSeconds is int) return durationSeconds as int;
    if (durationSeconds != null) {
      return int.tryParse(durationSeconds.toString());
    }
    return null;
  }

  String? get fileSize {
    if (_fileSize != null && _fileSize!.isNotEmpty) return _fileSize;
    if (fileSizeBytes != null && fileSizeBytes! > 0) {
      if (fileSizeBytes! >= 1024 * 1024) {
        return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
      }
    }
    return null;
  }

  set fileSize(String? val) => _fileSize = val;

  static bool? _parseBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  LibraryItemData.fromJson(Map<String, dynamic> json)
      : relatedVideos = <RelatedVideoModel>[],
        photos = <PhotoItemModel>[] {
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
    _title = json['title']?.toString();
    _shortDescription = json['shortDescription']?.toString();
    _description = json['description']?.toString();
    publishedOn = json['publishedOn']?.toString();
    thumbnailPath = json['thumbnailPath']?.toString();
    durationSeconds = json['durationSeconds'];
    pageCount = json['pageCount'];
    fileSizeBytes = json['fileSizeBytes'] is int
        ? json['fileSizeBytes'] as int
        : int.tryParse(json['fileSizeBytes']?.toString() ?? '');
    primaryFilePath = json['primaryFilePath']?.toString();
    sortOrder = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : int.tryParse(json['sortOrder']?.toString() ?? '');
    canDownload = _parseBool(json['canDownload'] ?? json['CanDownload']);
    canShare = _parseBool(json['canShare'] ?? json['CanShare']);
    canOpenInBrowser = _parseBool(json['canOpenInBrowser'] ??
        json['CanOpenInBrowser'] ??
        json['canOpenInNewTab'] ??
        json['CanOpenInNewTab']);

    // Compatibility fields
    _id = json['id']?.toString() ?? libraryItemId?.toString();
    _date = json['date']?.toString() ?? publishedOn;
    _type = json['type']?.toString() ?? contentTypeCode;
    _duration = json['duration']?.toString();
    _downloadUrl = json['downloadUrl']?.toString() ?? primaryFilePath;
    _shareUrl = json['shareUrl']?.toString() ?? primaryFilePath;
    _audioUrl = json['audioUrl']?.toString() ?? primaryFilePath;
    _videoUrl = json['videoUrl']?.toString() ?? primaryFilePath;
    _fileSize = json['fileSize']?.toString();
    videoTitle = json['videoTitle']?.toString();
    about = json['about']?.toString();
    contentTitle = json['contentTitle']?.toString();
    content = json['content']?.toString();
    meaning = json['meaning']?.toString();
    author = json['author']?.toString();
    language = json['language']?.toString();
    totalPhotos = json['totalPhotos'] is int
        ? json['totalPhotos'] as int
        : int.tryParse(json['totalPhotos']?.toString() ?? '');
    _totalPages = json['totalPages'] is int
        ? json['totalPages'] as int
        : int.tryParse(json['totalPages']?.toString() ?? '');
    _thumbnail = json['thumbnail']?.toString() ?? thumbnailPath?.toString();

    if (json['relatedVideos'] is List) {
      relatedVideos = (json['relatedVideos'] as List)
          .map((e) => RelatedVideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (json['photos'] is List) {
      photos = (json['photos'] as List)
          .map((e) => PhotoItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
    jsonMap['title'] = _title;
    jsonMap['shortDescription'] = _shortDescription;
    jsonMap['publishedOn'] = publishedOn;
    jsonMap['thumbnailPath'] = thumbnailPath;
    jsonMap['durationSeconds'] = durationSeconds;
    jsonMap['pageCount'] = pageCount;
    jsonMap['fileSizeBytes'] = fileSizeBytes;
    jsonMap['primaryFilePath'] = primaryFilePath;
    jsonMap['sortOrder'] = sortOrder;
    jsonMap['canDownload'] = canDownload;
    jsonMap['canShare'] = canShare;
    jsonMap['canOpenInBrowser'] = canOpenInBrowser;
    return jsonMap;
  }

  LibraryItemData copyWith({
    int? libraryItemId,
    int? libraryCategoryId,
    String? categoryName,
    String? categoryIconName,
    String? categoryIconColor,
    int? libraryContentTypeId,
    String? contentTypeCode,
    String? contentTypeName,
    String? contentTypeBadge,
    String? contentTypeIconName,
    String? contentTypeIconColor,
    String? title,
    String? shortDescription,
    String? description,
    String? publishedOn,
    String? thumbnailPath,
    dynamic durationSeconds,
    dynamic pageCount,
    int? fileSizeBytes,
    String? primaryFilePath,
    int? sortOrder,
    bool? canDownload,
    bool? canShare,
    bool? canOpenInBrowser,
    String? id,
    String? date,
    String? type,
    String? duration,
    String? downloadUrl,
    String? shareUrl,
    String? audioUrl,
    String? videoUrl,
    String? fileSize,
    int? totalPhotos,
    String? videoTitle,
    String? about,
    String? contentTitle,
    String? content,
    String? meaning,
    String? author,
    String? language,
    int? totalPages,
    String? thumbnail,
    List<RelatedVideoModel>? relatedVideos,
    List<PhotoItemModel>? photos,
  }) {
    return LibraryItemData(
      libraryItemId: libraryItemId ?? this.libraryItemId,
      libraryCategoryId: libraryCategoryId ?? this.libraryCategoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconName: categoryIconName ?? this.categoryIconName,
      categoryIconColor: categoryIconColor ?? this.categoryIconColor,
      libraryContentTypeId: libraryContentTypeId ?? this.libraryContentTypeId,
      contentTypeCode: contentTypeCode ?? this.contentTypeCode,
      contentTypeName: contentTypeName ?? this.contentTypeName,
      contentTypeBadge: contentTypeBadge ?? this.contentTypeBadge,
      contentTypeIconName: contentTypeIconName ?? this.contentTypeIconName,
      contentTypeIconColor: contentTypeIconColor ?? this.contentTypeIconColor,
      title: title ?? _title,
      shortDescription: shortDescription ?? _shortDescription,
      description: description ?? _description,
      publishedOn: publishedOn ?? this.publishedOn,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pageCount: pageCount ?? this.pageCount,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      primaryFilePath: primaryFilePath ?? this.primaryFilePath,
      sortOrder: sortOrder ?? this.sortOrder,
      canDownload: canDownload ?? this.canDownload,
      canShare: canShare ?? this.canShare,
      canOpenInBrowser: canOpenInBrowser ?? this.canOpenInBrowser,
      id: id ?? _id,
      date: date ?? _date,
      type: type ?? _type,
      duration: duration ?? _duration,
      downloadUrl: downloadUrl ?? _downloadUrl,
      shareUrl: shareUrl ?? _shareUrl,
      audioUrl: audioUrl ?? _audioUrl,
      videoUrl: videoUrl ?? _videoUrl,
      fileSize: fileSize ?? _fileSize,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      videoTitle: videoTitle ?? this.videoTitle,
      about: about ?? this.about,
      contentTitle: contentTitle ?? this.contentTitle,
      content: content ?? this.content,
      meaning: meaning ?? this.meaning,
      author: author ?? this.author,
      language: language ?? this.language,
      totalPages: totalPages ?? _totalPages,
      thumbnail: thumbnail ?? _thumbnail,
      relatedVideos: relatedVideos ?? this.relatedVideos,
      photos: photos ?? this.photos,
    );
  }
}

class Pagination {
  int? currentPage;
  int? pageSize;
  int? totalCount;
  int? totalPages;
  bool? hasPreviousPage;
  bool? hasNextPage;

  Pagination({
    this.currentPage,
    this.pageSize,
    this.totalCount,
    this.totalPages,
    this.hasPreviousPage,
    this.hasNextPage,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'] is int
        ? json['currentPage'] as int
        : int.tryParse(json['currentPage']?.toString() ?? '');
    pageSize = json['pageSize'] is int
        ? json['pageSize'] as int
        : int.tryParse(json['pageSize']?.toString() ?? '');
    totalCount = json['totalCount'] is int
        ? json['totalCount'] as int
        : int.tryParse(json['totalCount']?.toString() ?? '');
    totalPages = json['totalPages'] is int
        ? json['totalPages'] as int
        : int.tryParse(json['totalPages']?.toString() ?? '');
    hasPreviousPage = json['hasPreviousPage'] as bool?;
    hasNextPage = json['hasNextPage'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['currentPage'] = currentPage;
    jsonMap['pageSize'] = pageSize;
    jsonMap['totalCount'] = totalCount;
    jsonMap['totalPages'] = totalPages;
    jsonMap['hasPreviousPage'] = hasPreviousPage;
    jsonMap['hasNextPage'] = hasNextPage;
    return jsonMap;
  }
}

class PhotoItemModel {
  final String url;
  final String? caption;

  PhotoItemModel({required this.url, this.caption});

  factory PhotoItemModel.fromJson(Map<String, dynamic> json) {
    return PhotoItemModel(
      url: json['url']?.toString() ?? '',
      caption: json['caption']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'caption': caption};
}

class RelatedVideoModel {
  final String id;
  final String title;
  final String duration;
  final String thumbnail;
  final String videoUrl;

  RelatedVideoModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.thumbnail,
    required this.videoUrl,
  });

  factory RelatedVideoModel.fromJson(Map<String, dynamic> json) {
    return RelatedVideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'thumbnail': thumbnail,
        'videoUrl': videoUrl,
      };
}

typedef Data = LibraryItemData;
typedef LibraryItemModel = LibraryItemData;
