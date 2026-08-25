import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class GenderMapper {
  static String? getLabelKey(String? gender) {
    if (gender == null || gender.isEmpty) return null;

    switch (gender.toLowerCase()) {
      case 'male':
        return LK.male;
      case 'female':
        return LK.female;
      default:
        return null;
    }
  }
}

class MaritalStatusMapper {
  static String? getLabelKey(String? status) {
    if (status == null || status.isEmpty) return null;

    final normalized = status.toLowerCase().replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

    switch (normalized) {
      case 'married':
      case 'પરિણીત':
        return LK.married;
      case 'unmarried':
      case 'single':
      case 'અપરિણીત':
      case 'સિંગલ':
        return LK.unmarried;
      case 'widow':
      case 'વિધવા':
        return LK.widow;
      case 'widower':
      case 'વિધુર':
        return LK.widower;
      case 'divorced':
      case 'છૂટાછેડા':
        return LK.divorced;
      default:
        return null;
    }
  }
}

class RelationMapper {
  static String? getLabelKey(String? relation) {
    if (relation == null || relation.isEmpty) return null;

    switch (relation.toLowerCase()) {
      case 'self':
        return LK.self;
      case 'wife':
        return LK.wife;
      default:
        return relation;
    }
  }
}

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