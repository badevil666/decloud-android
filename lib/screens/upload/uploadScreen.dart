import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants.dart';
import '../../widgets/animatedCloudLottie.dart';
import '../../widgets/uploadButton.dart';
import '../../widgets/night_sky_background.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
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
