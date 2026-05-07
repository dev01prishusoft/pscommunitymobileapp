class ApiEndpoints {
  static const String login = '/api/v1/auth/login';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String memberLogin = '/api/v1/auth/member-login';
  static const String memberUpdatePassword = '/api/v1/auth/member-update-password';
  
  // Features
  static const String members = '/api/v1/member/list';
  static const String memberSearch = '/api/v1/member/MemberSearch';
  static const String familyAreas = '/api/v1/family/GetFamilyAreaForSamaj';
  static const String getFamiliesByArea = '/api/v1/family/GetFamilyByArea';
  static const String families = '/api/v1/Area/list';
  static const String committees = '/api/v1/committee/list';
  static const String payments = '/api/v1/PaymentMode/list';
  static const String occupations = '/api/v1/Occupation/list';
  static const String business = '/api/v1/AddressType/list';
  static const String marriage = '/api/v1/marriage/list';
  static const String unmarriedCount = '/api/v1/metrimonial/UnMarriedCount';
  static const String languageDropdown = '/api/v1/member/language-dropdown';
  static const String memberDetail = '/api/v1/member';
  static const String memberAddress = '/api/v1/member-address/member';
  static const String samajDetail = '/api/v1/member/samaj-detail';
  
  // Dropdowns
  static const String stateDropdown = '/api/v1/state/dropdown';
  static const String districtDropdown = '/api/v1/district/dropdown';
  static const String talukaDropdown = '/api/v1/Taluka/dropdown';
}
