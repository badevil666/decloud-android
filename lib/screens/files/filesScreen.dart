import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/files/file_record.dart';
import '../../core/files/files_service.dart';
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
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FileRecord> get _filtered => _query.isEmpty
      ? _files
      : _files.where((f) => f.filename.toLowerCase().contains(_query.toLowerCase())).toList();

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

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _fetchFiles,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
              ),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'No files uploaded yet.' : 'No results for "$_query".',
          style: TextStyle(color: kTextSecondary),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _buildFileItem(_filtered[i]),
      ),
    );
  }

  Widget _buildFileItem(FileRecord file) {
    final sizeLabel = _formatSize(file.filesize);
    final statusColor = _statusColor(file.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insert_drive_file_rounded, color: Colors.blueAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.filename,
                  style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(sizeLabel, style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('${file.numberOfChunks} chunks', style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('×${file.replicationFactor}', style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              file.status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
