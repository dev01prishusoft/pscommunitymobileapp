import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/locales/en_US.json');
  if (!file.existsSync()) return;

  final content = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(content);

  final seen = <String>{};
  bool hasDuplicates = false;

  for (final value in jsonMap.values) {
    final strValue = value.toString();
    if (seen.contains(strValue)) {
      hasDuplicates = true;
    }
    seen.add(strValue);
  }

  if (hasDuplicates) {
    exit(1);
  }
}
