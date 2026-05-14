import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class RoleMapper {
  /// Returns the localization key for a given role string.
  /// Since backend roles might be dynamic, if it doesn't match known
  /// static role keys, it returns null instead of falling back to raw values.
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
        if (kDebugMode) debugPrint('Unknown role: $role');
        return null;
    }
  }
}
