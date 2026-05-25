// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final lkFile = File('lib/core/localization/translation_keys.dart');
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');

  if (!lkFile.existsSync() || !enFile.existsSync() || !guFile.existsSync()) {
    print('Files not found');
    return;
  }

  final lkContent = lkFile.readAsStringSync();
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final guJson = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;

  final regex = RegExp(r"static const String \w+ = '([^']+)'");
  final matches = regex.allMatches(lkContent);

  final missingEn = <String>[];
  final missingGu = <String>[];

  for (final match in matches) {
    final value = match.group(1)!;
    if (!enJson.containsKey(value)) {
      missingEn.add(value);
    }
    if (!guJson.containsKey(value)) {
      missingGu.add(value);
    }
  }

  print('Missing in en_US.json: ${missingEn.length}');
  for (final key in missingEn) {
    print('  - $key');
  }

  print('\nMissing in gu_IN.json: ${missingGu.length}');
  for (final key in missingGu) {
    print('  - $key');
  }
}
