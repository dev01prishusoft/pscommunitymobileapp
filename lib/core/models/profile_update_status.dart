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
    final key = (json['keyName'] ??
            json['fieldName'] ??
            json['fieldKey'] ??
            json['columnName'] ??
            json['propertyName'] ??
            '')
        .toString();

    final reqId = json['approvalRequestId'] as int? ??
        json['memberUpdateRequestId'] as int? ??
        json['id'] as int? ??
        (int.tryParse(json['approvalRequestId']?.toString() ?? '') ?? 0);

    final statusStr = (json['status'] ??
            json['approvalStatus'] ??
            json['requestStatus'] ??
            '')
        .toString();

    final oldVal = (json['oldValue'] ??
            json['previousValue'] ??
            json['currentValue'])
        ?.toString();

    final newVal = (json['newValue'] ??
            json['updatedValue'] ??
            json['requestedValue'])
        ?.toString();

    return ProfileUpdateStatus(
      approvalRequestId: reqId,
      keyName: key,
      oldValue: oldVal,
      newValue: newVal,
      status: statusStr,
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
