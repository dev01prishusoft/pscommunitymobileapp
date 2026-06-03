import 'dart:io';
import 'dart:convert';

void main() {
  final guFile = File('assets/locales/gu_IN.json');
  var guMap = jsonDecode(guFile.readAsStringSync());
  
  guMap['From cannot be greater than To'] = 'શરૂઆતની રકમ અંતિમ રકમ કરતાં વધુ ન હોઈ શકે.';
  
  guFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(guMap));
  
  print('done');
}
