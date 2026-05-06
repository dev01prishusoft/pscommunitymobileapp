class ApiEndpoints {
  static const String login = '/api/v1/auth/login';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String memberLogin = '/api/v1/auth/member-login';
  static const String memberUpdatePassword = '/api/v1/auth/member-update-password';
  
  // Features
  static const String members = '/api/v1/member/list';
  static const String families = '/api/v1/Area/list';
  static const String committees = '/api/v1/CommitteeRole/list';
  static const String payments = '/api/v1/PaymentMode/list';
  static const String occupations = '/api/v1/Occupation/list';
  static const String business = '/api/v1/AddressType/list';
  static const String marriage = '/api/v1/marriage/list';
}
