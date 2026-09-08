import 'package:pscommunitymobileapp/core/module_permission/models/module_permission_model.dart';

export 'package:pscommunitymobileapp/core/module_permission/models/module_permission_model.dart';

typedef Modules = ModulePermissionModel;

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
    this.modules,
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
  final List<ModulePermissionModel>? modules;
}
