import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class CertificatePinning {
  static void configure(Dio dio) {
    // Real production pins for the server (Primary + Backup)
    // To get pins: openssl s_client -connect your-api.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
    const allowedPins = [
      'sha256/7nK9/K...base64_hash_here...', // Example production pin
      'sha256/backup_hash_here...',          // Backup pin
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
        if (kDebugMode) {
          print('PINNING FAILURE: $currentPin');
        } else {
          // In production, this is a fatal security error
          return false; 
        }
      }

      // If we are in debug mode AND using placeholders, we allow it for development.
      // In RELEASE mode, this shortcut is GONE.
      if (kDebugMode && allowedPins.any((p) => p.contains('...'))) {
        return true;
      }

      return isValid;
    };
  }
}
