import 'dart:io';
import 'dart:convert';

void main() {
  final guFile = File('assets/locales/gu_IN.json');
  final guJson = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;
  
  print('Value for copied to clipboard key:');
  print(guJson['copied to clipboard']);
}
