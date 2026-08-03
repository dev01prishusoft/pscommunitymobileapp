class ProfileUpdateStatus {
  ProfileUpdateStatus({
    required this.approvalRequestId,
    required this.keyName,
    this.oldValue,
    this.newValue,
    required this.status,
    this.rawJson = '',
  });

  factory ProfileUpdateStatus.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateStatus(
      approvalRequestId: json['approvalRequestId'] as int? ?? 0,
      keyName: json['keyName'] as String? ?? '',
      oldValue: json['oldValue']?.toString(),
      newValue: json['newValue']?.toString(),
      status: json['status'] as String? ?? '',
      rawJson: json.toString(),
    );
  }

  final int approvalRequestId;
  final String keyName;
  final String? oldValue;
  final String? newValue;
  final String status;
  final String rawJson;

  bool get isRequested => status == 'Requested';
  bool get isRejected => status == 'Rejected';
  bool get isApproved => status == 'Approved';
}
