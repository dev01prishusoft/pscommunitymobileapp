import 'dart:io';
import 'dart:convert';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');
  
  final enMap = jsonDecode(enFile.readAsStringSync());
  final guMap = jsonDecode(guFile.readAsStringSync());
  
  enMap['Notifications'] = 'Notifications';
  enMap['No notifications found'] = 'No notifications found';

  guMap['Notifications'] = 'નોટિફિકેશન';
  guMap['No notifications found'] = 'કોઈ નોટિફિકેશન મળ્યા નથી';
  
  enFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(enMap));
  guFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(guMap));
    // ignore: avoid_print
  print('Translations updated.');
}
