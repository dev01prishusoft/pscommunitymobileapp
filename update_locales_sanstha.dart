import 'dart:io';
import 'dart:convert';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');
  
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final guJson = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;
  
  final newKeys = {
    'community': ['COMMUNITY', 'સમાજ'],
    'samaj_sanstha_description': ['Discover community organizations, trust boards, and groups working together.', 'સમાજની સંસ્થાઓ, ટ્રસ્ટ બોર્ડ અને સાથે મળીને કામ કરતા જૂથો શોધો.']
  };

  newKeys.forEach((key, values) {
    enJson[key] = values[0];
    guJson[key] = values[1];
  });

  enFile.writeAsStringSync(jsonEncode(enJson));
  guFile.writeAsStringSync(jsonEncode(guJson));
  print('Updated locales.');
}
