import 'dart:io';
import 'dart:convert';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');
  
  var enMap = jsonDecode(enFile.readAsStringSync());
  var guMap = jsonDecode(guFile.readAsStringSync());
  
  enMap['From cannot be greater than To'] = 'From cannot be greater than To';
  guMap['From cannot be greater than To'] = 'પ્રારંભ અંત કરતાં વધુ ન હોઈ શકે';
  
  enFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(enMap));
  guFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(guMap));
  
  print('done');
}
