import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../auth/auth_service.dart';
import '../config/api_config_service.dart';
import '../config/relay_config_service.dart';
import 'file_processor.dart';
import 'relay_transfer_service.dart';
import 'upload_models.dart';

class UploadService {
  /// Full upload flow:
  /// 1. Process file in an isolate (build manifest + keep chunks in memory)
  /// 2. POST manifest to /client/upload → receive peer assignments
  /// 3. Transfer chunks to each peer concurrently via relay WebSocket
  static Future<void> upload({
    required String filePath,
    required int numberOfChunks,
    required int replicationFactor,
    required DateTime endDate,
  }) async {
    final baseUrl = await ApiConfigService.getBaseUrl();
    final relayUrl = await RelayConfigService.getBaseUrl();
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated. Please log in first.');

    // Step 1: Process file off the UI thread — manifest + chunks stay in memory
    print('[Upload] Processing file: $filePath');
    final result = await Isolate.run(() => processFile(
          filePath,
          numberOfChunks,
          replicationFactor,
          endDate,
        ));
    print('[Upload] File processed — ${result.chunks.length} chunk(s)');

    // Step 2: POST manifest to backend
    print('[Upload] POSTing manifest to $baseUrl/client/upload');
    final payload = result.manifest.toJson()..['token'] = token;
    final response = await http.post(
      Uri.parse('$baseUrl/client/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }

    final uploadResponse = UploadResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    print('[Upload] Got ${uploadResponse.peers.length} peer(s) for file ${uploadResponse.fileId}');

    // Step 3: Transfer chunks to each peer concurrently
    await Future.wait(
      uploadResponse.peers.entries.map((entry) {
        final peerId = entry.key;
        final assignment = entry.value;
        print('[Upload] Starting relay to peer $peerId — chunks ${assignment.chunkIndexes}');
        return RelayTransferService.transferToPeer(
          relayBaseUrl: relayUrl,
          peerToken: assignment.token,
          chunkIndexes: assignment.chunkIndexes,
          chunks: result.chunks,
          chunkInfos: result.manifest.chunkInfo,
        );
      }),
    );

    print('[Upload] All chunks delivered for file ${uploadResponse.fileId}');
  }
}
