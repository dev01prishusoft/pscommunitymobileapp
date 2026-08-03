class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.isDefaultPassword = false,
    this.accessTokenExpiry,
    this.memberId,
    this.samajId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.deviceUniqueId,
    this.primaryColor,
    this.secondaryColor,
  });
  final String accessToken;
  final String refreshToken;
  final bool isDefaultPassword;
  final String? accessTokenExpiry;
  final int? memberId;
  final int? samajId;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? deviceUniqueId;
  final String? primaryColor;
  final String? secondaryColor;
}
