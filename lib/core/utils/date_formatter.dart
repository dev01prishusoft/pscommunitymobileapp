import 'package:intl/intl.dart';

String formatDate(DateTime date, {String locale = 'en_US'}) {
  final formatter = DateFormat.yMMMd(locale);
  return formatter.format(date);
}
