import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants.dart';
import '../../core/upload/upload_service.dart';
import '../../widgets/animatedCloudLottie.dart';
import '../../widgets/uploadButton.dart';
import '../../widgets/night_sky_background.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<String> _selectedFiles = [];
  String? _selectedDirectory;

  void _clearSelection() {
    setState(() {
      _selectedFiles = [];
      _selectedDirectory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Upload Files"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBackgroundColor,
        foregroundColor: kTextPrimary,
      ),
      body: NightSkyBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedFiles.isEmpty && _selectedDirectory == null) ...[
                      const AnimatedUploadCloudLottie(size: 140),

                      const SizedBox(height: 32),

                      const Text(
                        "Upload your files",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Securely store and access your files anytime",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: kTextSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 🚀 Upload Button → Opens dropdown
                      UploadButton(
                        onTap: () {
                          _showUploadOptions(context);
                        },
                      ),
                    ] else ...[
                      // SHOW SELECTED FILES UI
                      Icon(
                        _selectedDirectory != null ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedDirectory != null
                            ? "Selected Folder"
                            : "Selected ${(_selectedFiles.length == 1) ? 'File' : 'Files'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedDirectory != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.folder_open, color: Colors.blueAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDirectory!.split('/').last,
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ..._selectedFiles.take(5).map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file, color: Colors.blueAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.split('/').last,
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            if (_selectedFiles.length > 5)
                              Text(
                                "+ ${_selectedFiles.length - 5} more files",
                                style: TextStyle(color: kTextSecondary, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearSelection,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Clear", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _showStorageSettings(context, filePaths: _selectedFiles.isNotEmpty ? _selectedFiles : null, directoryPath: _selectedDirectory);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Settings", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showStorageSettings(context, filePaths: _selectedFiles.isNotEmpty ? _selectedFiles : null, directoryPath: _selectedDirectory);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: kPrimaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const Text(
                                "Upload",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // 📥 UPLOAD OPTIONS BOTTOM SHEET
  // ============================
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬆️ Drag handle
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: kTextSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Upload Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 20),

              _uploadOption(
                Icons.insert_drive_file_rounded,
                "Upload File",
                "Choose a file from device",
                () async {
                  Navigator.pop(context);
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );

                  if (result != null) {
                    List<String> filePaths = result.paths.whereType<String>().toList();
                    debugPrint("Selected files: $filePaths");
                    if (mounted) {
                      setState(() {
                        _selectedFiles = filePaths;
                        _selectedDirectory = null;
                      });
                      _showStorageSettings(this.context, filePaths: filePaths);
                    }
                  } else {
                    debugPrint("File selection canceled");
                  }
                },
              ),

              _uploadOption(
                Icons.folder_open_rounded,
                "Upload Folder",
                "Upload multiple files",
                () async {
                  Navigator.pop(context);
                  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

                  if (selectedDirectory != null) {
                    debugPrint("Selected directory: $selectedDirectory");
                    if (mounted) {
                      setState(() {
                        _selectedFiles = [];
                        _selectedDirectory = selectedDirectory;
                      });
                      _showStorageSettings(this.context, directoryPath: selectedDirectory);
                    }
                  } else {
                    debugPrint("Folder selection canceled");
                  }
                },
              ),

              _uploadOption(
                Icons.camera_alt_rounded,
                "Scan Document",
                "Use camera to scan",
                () {
                  Navigator.pop(context);
                  debugPrint("Scan Document");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================
  // ⚙️ STORAGE SETTINGS
  // ============================
  void _showStorageSettings(BuildContext context, {List<String>? filePaths, String? directoryPath}) {
    int replicationFactor = 3;
    int numberOfChunks = 3;
    DateTime? endDate = DateTime.now().add(const Duration(days: 30));
    final TextEditingController replicationController = TextEditingController(text: "3");
    final TextEditingController chunksController = TextEditingController(text: "3");

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: kTextSecondary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        "Storage Settings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Replication Factor
                    Text("Replication Factor", style: TextStyle(color: kTextSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: replicationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (value) {
                        replicationFactor = int.tryParse(value) ?? 3;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Number of Chunks
                    Text("Number of Chunks", style: TextStyle(color: kTextSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: chunksController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (value) {
                        numberOfChunks = int.tryParse(value) ?? 3;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Duration / End Date
                    Text("End Date", style: TextStyle(color: kTextSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.blueAccent,
                                  onPrimary: Colors.white,
                                  surface: kCardColor,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              endDate != null ? "${endDate!.toLocal()}".split(' ')[0] : "Select Date",
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const Icon(Icons.calendar_month_rounded, color: Colors.blueAccent),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          // Resolve the list of file paths to process
                          List<String> paths = [];
                          if (filePaths != null) {
                            paths = filePaths;
                          } else if (directoryPath != null) {
                            final dir = Directory(directoryPath);
                            paths = dir
                                .listSync(recursive: true)
                                .whereType<File>()
                                .map((f) => f.path)
                                .toList();
                          }

                          if (paths.isEmpty) return;
                          Navigator.pop(context);

                          // Show processing indicator
                          showDialog(
                            context: this.context,
                            barrierDismissible: false,
                            builder: (_) => const AlertDialog(
                              backgroundColor: kCardColor,
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text('Processing file…', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          );

                          try {
                            for (final path in paths) {
                              await UploadService.upload(
                                filePath: path,
                                numberOfChunks: numberOfChunks,
                                replicationFactor: replicationFactor,
                                endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                              );
                            }
                            if (mounted) {
                              Navigator.of(this.context).pop(); // dismiss dialog
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Upload successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _clearSelection();
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(this.context).pop(); // dismiss dialog
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Upload failed: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: kPrimaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "Confirm & Upload",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================
  // 📄 SINGLE OPTION TILE
  // ============================
  Widget _uploadOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // 🌈 Gradient Icon
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(width: 14),

            // 📝 Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: kTextSecondary),
          ],
        ),
      ),
    );
  }
}
