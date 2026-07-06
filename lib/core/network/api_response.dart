import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ApiResponse<T> {
  ApiResponse({required this.succeeded, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    if (json['succeeded'] != true) {
      throw ServerFailure(
        json['message']?.toString() ?? 'Server error occurred',
      );
    }

    return ApiResponse<T>(
      succeeded: json['succeeded'] as bool? ?? false,
      message: json['message'] as String?,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
    );
  }
  final bool succeeded;
  final String? message;
  final T? data;
}

class PaginatedResponse<T> {
  PaginatedResponse({
    required this.succeeded,
    this.message,
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.unreadCount = 0,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    String listKey,
    T Function(Object? json) fromJsonT,
  ) {
    if (json['succeeded'] != true) {
      throw ServerFailure(
        json['message']?.toString() ?? 'Server error occurred',
      );
    }

    final dataObj = json['data'];
    List<dynamic> list = [];
    int pageNumber = 1, pageSize = 20, totalRecords = 0, totalPages = 0, unreadCount = 0;

    if (dataObj is Map<String, dynamic>) {
      list = (dataObj[listKey] ?? dataObj['data']) as List? ?? [];
      pageNumber = dataObj['pageNumber'] as int? ?? 1;
      pageSize = dataObj['pageSize'] as int? ?? 20;
      totalRecords = (dataObj['totalRecords'] ?? dataObj['totalCount']) as int? ?? 0;
      totalPages = dataObj['totalPages'] as int? ?? 0;
      unreadCount = dataObj['unreadCount'] as int? ?? 0;
    } else if (dataObj is List) {
      list = dataObj;
    }

    return PaginatedResponse<T>(
      succeeded: json['succeeded'] as bool? ?? false,
      message: json['message'] as String?,
      data: list.map((e) => fromJsonT(e)).toList(),
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalRecords: totalRecords,
      totalPages: totalPages,
      unreadCount: unreadCount,
    );
  }
  final bool succeeded;
  final String? message;
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final int unreadCount;
}
