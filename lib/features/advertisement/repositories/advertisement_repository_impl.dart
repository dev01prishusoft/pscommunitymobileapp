import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../models/advertisement_tracking_event.dart';
import 'advertisement_repository.dart';

class AdvertisementRepositoryImpl implements AdvertisementRepository {
  final ApiClient _apiClient;

  AdvertisementRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<Advertisement>>> getByPlacement(
    AdPlacement placement, {
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.advertisementsByPlacement(placement.code, limit: limit),
        queryParameters: null,
      );

      final data = response.data;
      if (data == null) {
        return const Success<List<Advertisement>>([]);
      }

      final rawList = data is Map<String, dynamic>
          ? (data['data'] as List<dynamic>? ?? [])
          : (data is List ? data : []);

      final ads = <Advertisement>[];
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            final ad = Advertisement.fromJson(item);
            if (ad.isValid) {
              ads.add(ad);
            }
          } catch (_) {
            // Non-fatal: skip malformed items
          }
        }
      }

      // If notifications placement is empty, fallback to check announcements (or vice-versa)
      if (ads.isEmpty &&
          (placement == AdPlacement.notifications ||
              placement == AdPlacement.announcements)) {
        final fallbackCode = placement == AdPlacement.notifications
            ? 'announcements'
            : 'notifications';
        try {
          final fallbackResp = await _apiClient.get(
            ApiEndpoints.advertisementsByPlacement(fallbackCode, limit: limit),
          );
          final fbData = fallbackResp.data;
          final fbList = fbData is Map<String, dynamic>
              ? (fbData['data'] as List<dynamic>? ?? [])
              : (fbData is List ? fbData : []);
          for (final item in fbList) {
            if (item is Map<String, dynamic>) {
              try {
                final ad = Advertisement.fromJson(item);
                if (ad.isValid) ads.add(ad);
              } catch (_) {}
            }
          }
        } catch (_) {}
      }

      return Success(ads);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Advertisement>> getById(int id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.advertisementDetail(id),
      );

      final data = response.data;
      if (data == null) {
        return Error(ServerFailure('Advertisement not found'));
      }

      final item = data is Map<String, dynamic> && data['data'] != null
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      final ad = Advertisement.fromJson(item);
      if (!ad.isValid) {
        return Error(ServerFailure('Advertisement is no longer available'));
      }

      return Success(ad);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PaginatedResponse<Advertisement>>> getList({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.advertisementList,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      final body = response.data;
      if (body is Map<String, dynamic>) {
        final dataObj = body['data'];
        List<dynamic> list = [];
        int pageNumber = page;
        int size = pageSize;
        int totalRecords = 0;
        int totalPages = 1;

        if (dataObj is Map<String, dynamic>) {
          list = (dataObj['items'] ?? dataObj['data'] ?? dataObj['advertisements']) as List? ?? [];
          pageNumber = (dataObj['pageNumber'] ?? dataObj['page']) as int? ?? page;
          size = (dataObj['pageSize'] ?? dataObj['size']) as int? ?? pageSize;
          totalRecords = (dataObj['totalRecords'] ?? dataObj['totalCount']) as int? ?? list.length;
          totalPages = (dataObj['totalPages'] ?? ((totalRecords / size).ceil())) as int? ?? 1;
        } else if (dataObj is List) {
          list = dataObj;
          totalRecords = list.length;
        } else if (body['items'] is List) {
          list = body['items'] as List;
          pageNumber = (body['pageNumber'] ?? body['page']) as int? ?? page;
          size = (body['pageSize'] ?? body['size']) as int? ?? pageSize;
          totalRecords = (body['totalRecords'] ?? body['totalCount']) as int? ?? list.length;
          totalPages = (body['totalPages'] ?? ((totalRecords / size).ceil())) as int? ?? 1;
        }

        final ads = <Advertisement>[];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              final ad = Advertisement.fromJson(item);
              if (ad.isValid) {
                ads.add(ad);
              }
            } catch (_) {}
          }
        }

        return Success(
          PaginatedResponse<Advertisement>(
            succeeded: true,
            data: ads,
            pageNumber: pageNumber,
            pageSize: size,
            totalRecords: totalRecords,
            totalPages: totalPages,
          ),
        );
      }

      return Error(ServerFailure('Invalid response structure'));
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> trackEvents(
    List<AdvertisementTrackingEvent> events,
  ) async {
    if (events.isEmpty) return const Success(null);
    try {
      await _apiClient.post(
        ApiEndpoints.advertisementBatchEvents,
        data: {
          'events': events.map((e) => e.toJson()).toList(),
        },
        options: Options(
          extra: {'skipErrorScreen': true, 'silent': true},
        ),
      );
      return const Success(null);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure(e.toString()));
    }
  }
}
