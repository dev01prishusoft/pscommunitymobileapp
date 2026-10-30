import 'package:intl/intl.dart';

String formatDate(DateTime date, {String locale = 'en_US'}) {
  final formatter = DateFormat.yMMMd(locale);
  return formatter.format(date);
}

String formatDateString(
  String? isoDate, {
  String format = 'dd/MM/yyyy',
  String fallback = '-',
}) {
  if (isoDate == null || isoDate.trim().isEmpty) return fallback;
  final cleaned = isoDate.trim();
  try {
    final parsedDate = DateTime.parse(cleaned);
    return DateFormat(format).format(parsedDate.toLocal());
  } catch (_) {
    try {
      if (cleaned.contains('/')) {
        final parts = cleaned.split(' ');
        final datePart = parts.first;
        final dParts = datePart.split('/');
        if (dParts.length == 3) {
          if (dParts[0].length == 4) {
            final parsedDate = DateTime(
              int.parse(dParts[0]),
              int.parse(dParts[1]),
              int.parse(dParts[2]),
            );
            return DateFormat(format).format(parsedDate);
          }
          if (dParts[2].length == 4) {
            final parsedDate = DateTime(
              int.parse(dParts[2]),
              int.parse(dParts[1]),
              int.parse(dParts[0]),
            );
            return DateFormat(format).format(parsedDate);
          }
        }
      } else if (cleaned.contains('-')) {
        final parts = cleaned.split(' ');
        final datePart = parts.first;
        final dParts = datePart.split('-');
        if (dParts.length == 3 && dParts[2].length == 4) {
          final parsedDate = DateTime(
            int.parse(dParts[2]),
            int.parse(dParts[1]),
            int.parse(dParts[0]),
          );
          return DateFormat(format).format(parsedDate);
        }
      }
      return cleaned.split('T').first;
    } catch (_) {
      try {
        return cleaned.split('T').first;
      } catch (_) {
        return cleaned;
      }
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
