import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');
  final keysFile = File('lib/core/localization/translation_keys.dart');

  final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final guMap = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;

  final keysContent = keysFile.readAsStringSync();
  final regex = RegExp(r"static String (\w+) = '([^']+)'");
  final matches = regex.allMatches(keysContent);
  
  int missingCount = 0;
  for (final match in matches) {
    final value = match.group(2)!;
    if (!enMap.containsKey(value)) {
      print('Missing in en: $value');
      missingCount++;
    }
  }
  print('Total missing in en: $missingCount');
}
