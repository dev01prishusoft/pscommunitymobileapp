class AdvertisementContact {
  final String name;
  final String mobile;
  final String email;
  final bool showActions;

  const AdvertisementContact({
    required this.name,
    required this.mobile,
    required this.email,
    required this.showActions,
  });

  factory AdvertisementContact.fromJson(Map<String, dynamic> json) {
    return AdvertisementContact(
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      showActions: json['showActions'] is bool
          ? json['showActions'] as bool
          : (json['showActions']?.toString().toLowerCase() == 'true' ||
              json['showActions'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'showActions': showActions,
    };
  }
}
