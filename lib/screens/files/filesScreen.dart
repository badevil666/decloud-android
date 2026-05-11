import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants.dart';
import '../../core/deals/deal_service.dart';
import '../../core/files/download_service.dart';
import '../../core/files/file_record.dart';
import '../../core/files/files_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../widgets/twinkling_stars_painter.dart';


class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<FileRecord> _files = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  // fileId → current status string while a download is in progress
  final Map<String, String> _downloadStatus = {};
  // track which STORED files we've already shown an escrow notification for
  final Set<String> _notifiedFiles = {};

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final files = await FilesService.getFiles();
      if (mounted) setState(() => _files = files);
      // Handle STORED files: auto-sign (if enabled) and show escrow notification
      final autoSignVal = await SecureStorage.read('auto_sign_deals');
      final autoSign = autoSignVal != 'false';
      for (final f in files) {
        if (f.status == 'STORED') {
          if (autoSign) DealService.autoSignDealsForFile(f.fileId);
          _maybeNotifyEscrow(f);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FileRecord> get _filtered => _query.isEmpty
      ? _files
      : _files
      .where((f) =>
      f.filename.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("My Files"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: kBackgroundColor,
        foregroundColor: kTextPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: TwinklingStars()),
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: kTextPrimary),
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: "Search files...",
                    hintStyle: TextStyle(color: kTextSecondary),
                    prefixIcon: Icon(Icons.search, color: kTextSecondary),
                    filled: true,
                    fillColor: kCardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // File list
              Expanded(child: _buildBody()),
            ],
          ),
        ],
      ),
    );
  }

  // Show a one-time SnackBar when a file first becomes STORED, showing peer escrow info
  Future<void> _maybeNotifyEscrow(FileRecord file) async {
    if (_notifiedFiles.contains(file.fileId)) return;
    _notifiedFiles.add(file.fileId);
    try {
      final deals = await DealService.fetchDealsForFile(file.fileId);
      if (!mounted || deals.isEmpty) return;
      final totalPeers = deals.length;
      final escrowWei = BigInt.tryParse(deals.first.peerEscrowWei) ?? BigInt.zero;
      final escrowDcld = escrowWei.toDouble() / 1e18;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'File stored across $totalPeers peer${totalPeers == 1 ? '' : 's'}. '
          'Peer escrow: ~${escrowDcld.toStringAsFixed(6)} DCLD/deal',
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 5),
      ));
    } catch (_) {}
  }

  Future<void> _downloadFile(FileRecord file) async {
    if (_downloadStatus.containsKey(file.fileId)) return;
    setState(() => _downloadStatus[file.fileId] = 'Starting...');

    try {
      final base = await getExternalStorageDirectory();
      final dir = Directory('${base!.path}/DeCloud');
      await dir.create(recursive: true);
      final outputPath = '${dir.path}/${file.filename}';

      await DownloadService.download(
        fileId: file.fileId,
        outputPath: outputPath,
        onProgress: (status) {
          if (mounted) setState(() => _downloadStatus[file.fileId] = status);
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saved: ${File(outputPath).uri.pathSegments.last}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _downloadStatus.remove(file.fileId));
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _fetchFiles,
      color: Colors.cyanAccent,
      child: _buildScrollableContent(),
    );
  }

  Widget _buildScrollableContent() {
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pull down to retry',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _query.isEmpty
                        ? 'No files uploaded yet.'
                        : 'No results for "$_query".',
                    style: TextStyle(color: kTextSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pull down to refresh',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _buildFileItem(_filtered[i]),
    );
  }

  Widget _buildFileItem(FileRecord file) {
    final sizeLabel      = _formatSize(file.filesize);
    final statusColor    = _statusColor(file.status);
    final downloadStatus = _downloadStatus[file.fileId];
    final isDownloading  = downloadStatus != null;

    // availability-driven visuals
    final tileColor = file.isAvailable ? kCardColor : kCardColor.withAlpha(100);
    final iconColor = file.isAvailable ? Colors.blueAccent : Colors.grey;
    final textColor = file.isAvailable ? kTextPrimary : kTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(file.isAvailable ? 90 : 40),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        children: [
          // ── File icon ────────────────────────────────────────────────────
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.insert_drive_file_rounded, color: iconColor),
          ),

          const SizedBox(width: 14),

          // ── File info (takes all remaining space) ─────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filename
                Text(
                  file.filename,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Size · chunks · replication
                Row(
                  children: [
                    Text(sizeLabel,
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    Text(' · ',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    Text('${file.numberOfChunks} chunks',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    Text(' · ',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    Text('×${file.replicationFactor}',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 6),

                // Availability indicator inline
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      file.isAvailable
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: 12,
                      color: file.isAvailable
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      file.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: file.isAvailable
                            ? Colors.greenAccent
                            : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Status badge + download button ────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  file.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                width: 30,
                child: isDownloading
                    ? const Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.download_rounded,
                          size: 22,
                          color: file.isAvailable
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        tooltip: file.isAvailable
                            ? 'Download'
                            : 'File unavailable',
                        onPressed: file.isAvailable
                            ? () => _downloadFile(file)
                            : null,
                      ),
              ),
            ],
          ),
        ],
        ), // end main Row
        if (downloadStatus != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  downloadStatus,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        ], // end Column children
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ALLOCATED': return Colors.greenAccent;
      case 'PENDING':   return Colors.orangeAccent;
      case 'FAILED':    return Colors.redAccent;
      default:          return kTextSecondary;
    }
  }
}