import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';

class CertificatePinning {
  static const List<String> primaryPins = [
    'sha256/PLACEHOLDER_PRIMARY_PIN_BASE64_1=',
    'sha256/PLACEHOLDER_PRIMARY_PIN_BASE64_2=',
  ];

  static const List<String> backupPins = [
    'sha256/PLACEHOLDER_BACKUP_PIN_BASE64_1=',
  ];

  static final DateTime pinExpiryDate = DateTime(2027, 12, 31);

  static void configure(Dio dio) {
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    adapter.createHttpClient = () {
      final client = HttpClient(
        context: SecurityContext(withTrustedRoots: true),
      );

      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          AppLogger.d('WARNING: Bypassing SSL Pinning in Debug Mode');
          return true;
        }
        return false;
      };

      return client;
    };

    adapter.validateCertificate =
        (X509Certificate? cert, String host, int port) {

          if (kDebugMode) return true;

          if (cert == null) return false;

          final expectedHost = Uri.parse(AppEnvironment.I.apiBaseUrl).host;
          if (host != expectedHost) {
            AppLogger.e('Host mismatch: $host != $expectedHost');
            return false;
          }

          final hash = sha256.convert(cert.der).bytes;
          final base64Hash = base64.encode(hash);
          final currentPin = 'sha256/$base64Hash';

          final allValidPins = [...primaryPins, ...backupPins];
          if (DateTime.now().isAfter(pinExpiryDate)) {
            AppLogger.e(
              'CRITICAL: Certificate pins have expired! Initiate rotation.',
            );
          }

          if (!allValidPins.contains(currentPin)) {
            AppLogger.e('PINNING FAILURE for $host. Invalid PIN: $currentPin');
            return false;
          }

          return true;
        };
  }
}
