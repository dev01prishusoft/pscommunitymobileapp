import 'dart:io';
import '../lib/core/localization/translation_keys.dart';

void main() {
  final keys = LK.allValues;
  final seen = <String>{};
  bool hasDuplicates = false;
  
  for (final key in keys) {
    if (seen.contains(key)) {
      print('Duplicate: $key');
      hasDuplicates = true;
    }
    seen.add(key);
  }
  
  if (hasDuplicates) {
    exit(1);
  } else {
    print('No duplicate LK values found.');
  }
}
