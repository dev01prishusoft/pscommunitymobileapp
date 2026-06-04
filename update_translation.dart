import 'dart:io';
import 'dart:convert';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');
  
  var enMap = jsonDecode(enFile.readAsStringSync());
  var guMap = jsonDecode(guFile.readAsStringSync());
  
  // Add to English
  enMap['Edit profile request sent'] = 'Edit profile request sent';
  
  // Add to Gujarati (User said: "it will also be same in gujarati translation")
  guMap['Edit profile request sent'] = 'Edit profile request sent';
  
  enFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(enMap));
  guFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(guMap));
  
  print('Translations updated.');
}
