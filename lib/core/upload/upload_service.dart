import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../auth/auth_service.dart';
import '../config/api_config_service.dart';
import 'file_processor.dart';

class UploadService {
  /// Processes the file (in a separate isolate) and POSTs the manifest.
  ///
  /// Throws on HTTP error or processing failure.
  static Future<void> upload({
    required String filePath,
    required int numberOfChunks,
    required int replicationFactor,
    required DateTime endDate,
  }) async {
    // Run heavy processing off the UI thread
    final manifest = await Isolate.run(() => processFile(
          filePath,
          numberOfChunks,
          replicationFactor,
          endDate,
        ));

    final baseUrl = await ApiConfigService.getBaseUrl();
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated. Please log in first.');

    final payload = manifest.toJson()..['token'] = token;
    final body = jsonEncode(payload);

    final response = await http.post(
      Uri.parse('$baseUrl/client/upload'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Upload failed: ${response.statusCode} ${response.body}');
    }
  }
}
