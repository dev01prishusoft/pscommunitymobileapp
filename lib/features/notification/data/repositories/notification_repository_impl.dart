import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/network/network_exception_mapper.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';
import 'package:pscommunitymobileapp/features/notification/data/repositories/notification_repository.dart';

import 'package:dio/dio.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<PaginatedResponse<MemberNotification>>> getNotifications(int page, int pageSize, {CancelToken? cancelToken}) {
    return _apiClient.getPaginated<MemberNotification>(
      ApiEndpoints.notifications,
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
      cancelToken: cancelToken,
      listKey: 'data',
      fromJsonT: (json) => MemberNotification.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<bool>> markAsRead(int notificationId, {CancelToken? cancelToken}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.markNotificationRead(notificationId),
        cancelToken: cancelToken,
      );
      final isSuccess = response.data['succeeded'] == true;
      return Success(isSuccess);
    } catch (e) {
      return Error(NetworkExceptionMapper.map(e));
    }
  }
}
