class MemberNotification {
  MemberNotification({
    required this.memberNotificationId,
    required this.memberId,
    required this.dailyNotificationId,
    required this.message,
    required this.sendTime,
    this.pageSource,
    this.pageText,
    required this.isRead,
    required this.createdAt,
  });

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    return MemberNotification(
      memberNotificationId: json['memberNotificationId'] as int? ?? 0,
      memberId: json['memberId'] as int? ?? 0,
      dailyNotificationId: json['dailyNotificationId'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      sendTime: json['sendTime'] as String? ?? '',
      pageSource: json['pageSource'] as String?,
      pageText: json['pageText'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final int memberNotificationId;
  final int memberId;
  final int dailyNotificationId;
  final String message;
  final String sendTime;
  final String? pageSource;
  final String? pageText;
  final bool isRead;
  final String createdAt;

  MemberNotification copyWith({
    int? memberNotificationId,
    int? memberId,
    int? dailyNotificationId,
    String? message,
    String? sendTime,
    String? pageSource,
    String? pageText,
    bool? isRead,
    String? createdAt,
  }) {
    return MemberNotification(
      memberNotificationId: memberNotificationId ?? this.memberNotificationId,
      memberId: memberId ?? this.memberId,
      dailyNotificationId: dailyNotificationId ?? this.dailyNotificationId,
      message: message ?? this.message,
      sendTime: sendTime ?? this.sendTime,
      pageSource: pageSource ?? this.pageSource,
      pageText: pageText ?? this.pageText,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
