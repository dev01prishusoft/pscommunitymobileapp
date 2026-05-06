class Member {
  final String name;
  final String info;
  final String location;

  const Member({
    required this.name,
    required this.info,
    required this.location,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] as String? ?? '',
      info: json['info'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}
