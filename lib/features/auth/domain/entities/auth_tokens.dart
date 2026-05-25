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
}
