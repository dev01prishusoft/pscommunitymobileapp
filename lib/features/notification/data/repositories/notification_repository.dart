import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';

import 'package:dio/dio.dart';

abstract class NotificationRepository {
  Future<Result<PaginatedResponse<MemberNotification>>> getNotifications(int page, int pageSize, {CancelToken? cancelToken});
  Future<Result<bool>> markAsRead(int notificationId, {CancelToken? cancelToken});
}
