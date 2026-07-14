import 'dart:io';

import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

void main() {
  final keys = LK.allValues;
  final seen = <String>{};
  bool hasDuplicates = false;

  for (final key in keys) {
    if (seen.contains(key)) {
      hasDuplicates = true;
    }
    seen.add(key);
  }

  if (hasDuplicates) {
    exit(1);
  } else {
  }
}
