import 'dart:math' as math;
import 'package:flutter/material.dart';

class AstrologicalSignInfo {
  final int id;
  final String englishName;
  final String gujaratiName;
  final String sanskritName;
  final double? siderealDegree;
  final bool isVedic;

  const AstrologicalSignInfo({
    required this.id,
    required this.englishName,
    required this.gujaratiName,
    required this.sanskritName,
    this.siderealDegree,
    required this.isVedic,
  });

  @override
  String toString() =>
      '$englishName ($gujaratiName) [ID: $id] ${isVedic ? "(Vedic: ${siderealDegree?.toStringAsFixed(2)}°)" : "(Western Sun Sign)"}';
}

class AstrologyCalculator {
  AstrologyCalculator._();
  static const List<AstrologicalSignInfo> signs = [
    AstrologicalSignInfo(
      id: 3,
      englishName: 'Aries',
      gujaratiName: 'મેષ',
      sanskritName: 'Mesha',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 4,
      englishName: 'Taurus',
      gujaratiName: 'વૃષભ',
      sanskritName: 'Vrishabha',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 5,
      englishName: 'Gemini',
      gujaratiName: 'મિથુન',
      sanskritName: 'Mithuna',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 17,
      englishName: 'Cancer',
      gujaratiName: 'કર્ક',
      sanskritName: 'Karka',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 7,
      englishName: 'Leo',
      gujaratiName: 'સિંહ',
      sanskritName: 'Simha',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 8,
      englishName: 'Virgo',
      gujaratiName: 'કન્યા',
      sanskritName: 'Kanya',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 9,
      englishName: 'Libra',
      gujaratiName: 'તુલા',
      sanskritName: 'Tula',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 10,
      englishName: 'Scorpio',
      gujaratiName: 'વૃશ્ચિક',
      sanskritName: 'Vrischika',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 11,
      englishName: 'Sagittarius',
      gujaratiName: 'ધનુ',
      sanskritName: 'Dhanu',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 12,
      englishName: 'Capricorn',
      gujaratiName: 'મકર',
      sanskritName: 'Makara',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 13,
      englishName: 'Aquarius',
      gujaratiName: 'કુંભ',
      sanskritName: 'Kumbha',
      isVedic: false,
    ),
    AstrologicalSignInfo(
      id: 14,
      englishName: 'Pisces',
      gujaratiName: 'મીન',
      sanskritName: 'Meena',
      isVedic: false,
    ),
  ];

  static AstrologicalSignInfo getSignById(int id) {
    return signs.firstWhere((s) => s.id == id, orElse: () => signs[0]);
  }

  static AstrologicalSignInfo calculateWesternSunSign(int month, int day) {
    int signId;
    switch (month) {
      case 1:
        signId = (day <= 19) ? 12 : 13;
        break;
      case 2:
        signId = (day <= 18) ? 13 : 14;
        break;
      case 3:
        signId = (day <= 20) ? 14 : 3;
        break;
      case 4:
        signId = (day <= 19) ? 3 : 4;
        break;
      case 5:
        signId = (day <= 20) ? 4 : 5;
        break;
      case 6:
        signId = (day <= 20) ? 5 : 17;
        break;
      case 7:
        signId = (day <= 22) ? 17 : 7;
        break;
      case 8:
        signId = (day <= 22) ? 7 : 8;
        break;
      case 9:
        signId = (day <= 22) ? 8 : 9;
        break;
      case 10:
        signId = (day <= 22) ? 9 : 10;
        break;
      case 11:
        signId = (day <= 21) ? 10 : 11;
        break;
      case 12:
        signId = (day <= 21) ? 11 : 12;
        break;
      default:
        signId = 3;
    }

    final base = getSignById(signId);
    return AstrologicalSignInfo(
      id: base.id,
      englishName: base.englishName,
      gujaratiName: base.gujaratiName,
      sanskritName: base.sanskritName,
      isVedic: false,
    );
  }

  static AstrologicalSignInfo calculateVedicMoonSign(
    int year,
    int month,
    int day,
    int hourIst,
    int minuteIst,
  ) {
    int utcHour = hourIst - 5;
    int utcMinute = minuteIst - 30;
    int utcDay = day;
    int utcMonth = month;
    int utcYear = year;

    if (utcMinute < 0) {
      utcMinute += 60;
      utcHour -= 1;
    }
    if (utcHour < 0) {
      utcHour += 24;
      final prevDate = DateTime(year, month, day).subtract(const Duration(days: 1));
      utcDay = prevDate.day;
      utcMonth = prevDate.month;
      utcYear = prevDate.year;
    }

    final double jd = _getJulianDate(utcYear, utcMonth, utcDay, utcHour, utcMinute, 0);
    final double t = (jd - 2451545.0) / 36525.0;
    final double tropicalMoon = _getMoonTropicalLongitude(t);
    final double ayanamsha = _getLahiriAyanamsha(t);
    double siderealMoon = (tropicalMoon - ayanamsha) % 360.0;
    if (siderealMoon < 0) siderealMoon += 360.0;

    final int rashiIndex = (siderealMoon ~/ 30) % 12;
    final base = signs[rashiIndex];

    return AstrologicalSignInfo(
      id: base.id,
      englishName: base.englishName,
      gujaratiName: base.gujaratiName,
      sanskritName: base.sanskritName,
      siderealDegree: siderealMoon,
      isVedic: true,
    );
  }

  static AstrologicalSignInfo? calculateSignFromStrings({
    String? dobString,
    String? tobString,
  }) {
    final date = parseDate(dobString);
    if (date == null) return null;

    final time = parseTime(tobString);
    if (time != null) {
      return calculateVedicMoonSign(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } else {
      return calculateWesternSunSign(date.month, date.day);
    }
  }

  static DateTime? parseDate(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.contains('-') || trimmed.contains('/')) {
      final delimiter = trimmed.contains('-') ? '-' : '/';
      final parts = trimmed.split(delimiter);
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2].split('T')[0].split(' ')[0]);
          if (y != null && m != null && d != null) {
            return DateTime(y, m, d);
          }
        } else {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2].split('T')[0].split(' ')[0]);
          if (y != null && m != null && d != null) {
            return DateTime(y, m, d);
          }
        }
      }
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return null;
  }

  static TimeOfDay? parseTime(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final isAm = RegExp(r'am', caseSensitive: false).hasMatch(trimmed);
    final isPm = RegExp(r'pm', caseSensitive: false).hasMatch(trimmed);

    final clean = trimmed.replaceAll(RegExp(r'[^\d:]'), '').trim();
    final parts = clean.split(':');
    if (parts.isEmpty || parts[0].isEmpty) return null;

    int? hour = int.tryParse(parts[0]);
    int minute = 0;
    if (parts.length >= 2) {
      minute = int.tryParse(parts[1]) ?? 0;
    }

    if (hour == null) return null;

    if (isPm && hour < 12) {
      hour += 12;
    } else if (isAm && hour == 12) {
      hour = 0;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static double _getJulianDate(int year, int month, int day, int hour, int minute, [int second = 0]) {
    final double decDay = day + (hour + minute / 60.0 + second / 3600.0) / 24.0;
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final int a = y ~/ 100;
    final int b = 2 - a + (a ~/ 4);
    final double jd = (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        decDay +
        b -
        1524.5;
    return jd;
  }

  static double _getMoonTropicalLongitude(double t) {
    const double deg2rad = math.pi / 180.0;

    final double l0 = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + (t * t * t) / 538841.0;
    final double d = 297.8501921 + 445267.1114034 * t - 0.0018819 * t * t + (t * t * t) / 545868.0;
    final double m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t * t;
    final double mp = 134.9633964 + 477198.8675055 * t + 0.0087414 * t * t + (t * t * t) / 69699.0;
    final double f = 93.2720950 + 483202.0175233 * t - 0.0036539 * t * t - (t * t * t) / 3526000.0;

    final double dr = d * deg2rad;
    final double mr = m * deg2rad;
    final double mpr = mp * deg2rad;
    final double fr = f * deg2rad;

    double dl = 6.288774 * math.sin(mpr) +
        1.274027 * math.sin(2 * dr - mpr) +
        0.658309 * math.sin(2 * dr) +
        0.213618 * math.sin(2 * mpr) -
        0.185116 * math.sin(mr) -
        0.114332 * math.sin(2 * fr) +
        0.058793 * math.sin(2 * dr - 2 * mpr) +
        0.057066 * math.sin(2 * dr - mr - mpr) +
        0.053322 * math.sin(2 * dr + mpr) +
        0.045758 * math.sin(2 * dr - mr) -
        0.040923 * math.sin(mr - mpr) -
        0.034720 * math.sin(dr) -
        0.030383 * math.sin(mr + mpr) +
        0.015327 * math.sin(2 * dr - 2 * fr) -
        0.012528 * math.sin(2 * dr + mr - mpr) +
        0.010980 * math.sin(2 * dr + mr) +
        0.010675 * math.sin(4 * dr - mpr) +
        0.010034 * math.sin(3 * mpr) +
        0.008548 * math.sin(4 * dr - 2 * mpr) -
        0.007888 * math.sin(2 * dr - mr + mpr) -
        0.006766 * math.sin(2 * dr + 2 * mpr) -
        0.005163 * math.sin(2 * dr - mpr - 2 * fr) +
        0.004987 * math.sin(2 * dr - 2 * mr) +
        0.004036 * math.sin(2 * dr - mr - 2 * fr) +
        0.003994 * math.sin(2 * dr + 2 * mpr - mr) +
        0.003861 * math.sin(4 * dr) +
        0.003665 * math.sin(2 * dr - 3 * mpr) -
        0.002689 * math.sin(mpr - 2 * fr) -
        0.002602 * math.sin(2 * dr - mpr + 2 * fr) +
        0.002390 * math.sin(2 * dr - 2 * mpr - mr) -
        0.002348 * math.sin(dr + mpr) +
        0.002236 * math.sin(2 * dr - 2 * mr - mpr) -
        0.002120 * math.sin(2 * mpr - 2 * fr) -
        0.002069 * math.sin(2 * dr + mr - 2 * mpr) +
        0.002048 * math.sin(2 * dr - 2 * mpr + mr) -
        0.001773 * math.sin(2 * dr - 2 * fr + mpr) -
        0.001595 * math.sin(2 * dr + 2 * fr) +
        0.001215 * math.sin(4 * dr - mr - mpr) -
        0.001110 * math.sin(2 * mpr + 2 * fr) +
        0.000892 * math.sin(dr - mpr) -
        0.000811 * math.sin(mr + 2 * fr) +
        0.000761 * math.sin(4 * dr - 2 * mpr - mr) +
        0.000717 * math.sin(2 * dr - 2 * mr + mpr) -
        0.000704 * math.sin(2 * mr - 2 * fr) +
        0.000693 * math.sin(2 * dr - mr - 2 * mpr) +
        0.000598 * math.sin(2 * dr - 2 * fr - mr) +
        0.000550 * math.sin(4 * dr + mpr) +
        0.000538 * math.sin(4 * mpr) +
        0.000521 * math.sin(4 * dr - mr) +
        0.000486 * math.sin(2 * dr - mpr + mr);

    final double a1 = 119.75 + 131.849 * t;
    final double a2 = 53.09 + 479264.290 * t;
    dl += 0.003964 * math.sin(a1 * deg2rad) +
        0.001957 * math.sin((l0 - f) * deg2rad) +
        0.002461 * math.sin(a2 * deg2rad);

    double longTrop = (l0 + dl) % 360.0;
    if (longTrop < 0) longTrop += 360.0;
    return longTrop;
  }

  static double _getLahiriAyanamsha(double t) {
    return 23.8580167 + 1.396971 * t - 0.000308 * t * t;
  }
}

