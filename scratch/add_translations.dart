import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('assets/locales/en_US.json');
  final guFile = File('assets/locales/gu_IN.json');

  final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final guMap = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;

  enMap['Bank acount'] = 'Bank account';
  guMap['Bank acount'] = 'બેંક ખાતું';

  enMap['Cash'] = 'Cash';
  guMap['Cash'] = 'રોકડ';

  enMap['Cheque'] = 'Cheque';
  guMap['Cheque'] = 'ચેક';

  enMap['Online'] = 'Online';
  guMap['Online'] = 'ઓનલાઇન';

  enMap['Completed'] = 'Completed';
  guMap['Completed'] = 'પૂર્ણ';

  enMap['Failed'] = 'Failed';
  guMap['Failed'] = 'નિષ્ફળ';

  enMap['Thank you for your payment!'] = 'Thank you for your payment!';
  guMap['Thank you for your payment!'] = 'તમારી ચુકવણી બદલ આભાર!';

  enFile.writeAsStringSync(jsonEncode(enMap));
  guFile.writeAsStringSync(jsonEncode(guMap));
}
