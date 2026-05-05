import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class CertificatePinning {
  static void configure(Dio dio) {
    if (kDebugMode) return;

    // ignore: unused_local_variable
    final allowedPins = [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    ];

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      
      // Pinning logic using allowedPins would go here
      // For now, we keep it as a documented pattern
      
      return client;
    };
  }
}
