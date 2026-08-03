class UnmarriedCount {
  UnmarriedCount({
    required this.genderId,
    required this.genderName,
    required this.count,
  });

  factory UnmarriedCount.fromJson(Map<String, dynamic> json) {
    return UnmarriedCount(
      genderId: json['genderId'] as int? ?? 0,
      genderName: json['genderName'] as String? ?? '',
      count: json['unMarriedCount'] as int? ?? 0,
    );
  }
  final int genderId;
  final String genderName;
  final int count;
}
