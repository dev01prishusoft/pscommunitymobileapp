import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pscommunitymobileapp/core/constants/api_constants.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void close() {
    _client.close();
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = decoded['message']?.toString() ??
          'Request failed (${response.statusCode})';
      throw Exception(errorMessage);
    }

    return decoded;
  }
}
