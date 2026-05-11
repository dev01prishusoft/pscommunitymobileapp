import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class CertificatePinning {
  static void configure(Dio dio) {
    // Real production pins for the server (Primary + Backup)
    // To get pins: openssl s_client -connect your-api.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
    const allowedPins = [
      'sha256/oBTD/ZWLoIUhpfzgjHtjfO/M0nohlVWgkYM7D/0A470=', // Primary: communityapi.prishusoft.com (Leaf Fingerprint)
      'sha256/lrzsBiZJdvN0YHearCjFp8/oo8Cq4RqP/O4FwL3fCMY=', // Backup: ISRG Root X1 (Root Fingerprint)
    ];

    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    adapter.createHttpClient = () {
      final client = HttpClient(
        context: SecurityContext(withTrustedRoots: true),
      );
      
      // Reject all certificates that are not trusted by the OS trust store
      // AND later subject them to the pinning check.
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('Certificate validation failed for $host. Allowing for debug.');
          return true; // Allow in debug
        }
        return false; // Reject in release
      };
      
      return client;
    };

    // Use validateCertificate for actual pinning (checking against specific hashes).
    adapter.validateCertificate = (X509Certificate? cert, String host, int port) {
      if (cert == null) return false;

      // Hash the certificate DER
      final hash = sha256.convert(cert.der).bytes;
      final base64Hash = base64.encode(hash);
      final currentPin = 'sha256/$base64Hash';

      final isValid = allowedPins.contains(currentPin);
      
      if (!isValid) {
        AppLogger.e('PINNING FAILURE for $host: $currentPin');
        if (kDebugMode) {
          AppLogger.d('Allowing pinning failure in debug mode. In production, this will fail.');
          return true; 
        }
        return false; 
      }

      return true;
    };
  }
}
