import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';

class EventsRepositoryImpl implements EventsRepositories {
  EventsRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<PaginatedResponse<EventsData>>> getEvents({
    String? searchQuery,
    String? type,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> params = {
      'TimePeriod': type,
      'Page': pageNumber,
      'PageSize': pageSize,
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['Search'] = searchQuery;
    }

    return await _apiClient.getPaginated<EventsData>(
      ApiEndpoints.eventList,
      queryParameters: params,
      cancelToken: cancelToken,
      listKey: 'data',
      fromJsonT: (json) => EventsData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<ApiResponse<EventDetailsData>>> getEventDetails({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getParsed<EventDetailsData>(
      ApiEndpoints.eventDetails(id),
      cancelToken: cancelToken,
      fromJsonT: (json) => EventDetailsData.fromJson(json as Map<String, dynamic>),
    );
  }
}
