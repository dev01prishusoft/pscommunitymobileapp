import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class RoleMapper {
  static String? getLabelKey(String? role) {
    if (role == null || role.isEmpty) return null;

    switch (role.toLowerCase().trim()) {
      case 'president':
        return LK.rolePresident;
      case 'vice president':
        return LK.roleVicePresident;
      case 'secretary':
        return LK.roleSecretary;
      case 'joint secretary':
        return LK.roleJointSecretary;
      case 'treasurer':
        return LK.roleTreasurer;
      case 'committee member':
        return LK.roleCommitteeMember;
      default:
        return null;
    }
  }
}
