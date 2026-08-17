import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';

abstract class EventsRepositories {
  Future<Result<PaginatedResponse<EventsData>>> getEvents({
    String? searchQuery,
    String type,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  });

  Future<Result<ApiResponse<EventDetailsData>>> getEventDetails({
    required int id,
    CancelToken? cancelToken,
  });
}
