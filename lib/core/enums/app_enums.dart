// ignore_for_file: sort_constructors_first
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  final String value;
  const Gender(this.value);

  static Gender? fromString(String val) {
    for (var g in Gender.values) {
      if (g.value.toLowerCase() == val.toLowerCase()) return g;
    }
    return null;
  }
}

enum MaritalStatus {
  unmarried('Unmarried'),
  married('Married'),
  widow('Widow'),
  divorced('Divorced');

  final String value;
  const MaritalStatus(this.value);

  static MaritalStatus? fromString(String val) {
    for (var s in MaritalStatus.values) {
      if (s.value.toLowerCase() == val.toLowerCase()) return s;
    }
    return null;
  }
}

enum BloodGroup {
  aPositive('A+'),
  aNegative('A-'),
  bPositive('B+'),
  bNegative('B-'),
  abPositive('AB+'),
  abNegative('AB-'),
  oPositive('O+'),
  oNegative('O-');

  final String value;
  const BloodGroup(this.value);

  static BloodGroup? fromString(String val) {
    for (var bg in BloodGroup.values) {
      if (bg.value.toLowerCase() == val.toLowerCase()) return bg;
    }
    return null;
  }
}

enum Relation {
  self('Self'),
  wife('Wife'),
  husband('Husband'),
  son('Son'),
  daughter('Daughter'),
  father('Father'),
  mother('Mother'),
  brother('Brother'),
  sister('Sister');

  final String value;
  const Relation(this.value);

  static Relation? fromString(String val) {
    for (var r in Relation.values) {
      if (r.value.toLowerCase() == val.toLowerCase()) return r;
    }
    return null;
  }
}
