import 'package:intl/intl.dart';

String formatDate(DateTime date, {String locale = 'en_US'}) {
  final formatter = DateFormat.yMMMd(locale);
  return formatter.format(date);
}

String formatDateString(String? isoDate, {String format = 'dd/MM/yyyy', String fallback = 'N/A'}) {
  if (isoDate == null || isoDate.isEmpty) return fallback;
  try {
    final parsedDate = DateTime.parse(isoDate);
    return DateFormat(format).format(parsedDate);
  } catch (_) {
    try {
      return isoDate.split('T').first;
    } catch (_) {
      return isoDate;
    }
  }
}

bool isDateInPast(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return false;
  try {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  } catch (_) {
    return false;
  }
}
