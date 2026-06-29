import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';

abstract class NotificationRepository {
  Future<Result<PaginatedResponse<MemberNotification>>> getNotifications(int page, int pageSize);
  Future<Result<bool>> markAsRead(int notificationId);
}
