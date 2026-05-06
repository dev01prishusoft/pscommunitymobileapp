class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final bool isDefaultPassword;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.isDefaultPassword = false,
  });
}
