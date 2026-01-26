import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/twinkling_stars_painter.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

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
      ),
      body: Stack(
        children: [
          // 🌌 Night sky – stars only
          const Positioned.fill(child: TwinklingStars()),

          // Foreground content (unchanged)
          Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: kTextPrimary),
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

              // 🏷 Filters
              _buildFilters(),

              const SizedBox(height: 10),

              // 📂 File List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildFileItem(
                      "Project_Brief_V2.pdf",
                      "5.2 MB",
                      Icons.picture_as_pdf_rounded,
                      const Color(0xFF2CB1FF),
                    ),
                    _buildFileItem(
                      "Holiday_Snaps.zip",
                      "88 MB",
                      Icons.folder_zip_rounded,
                      const Color(0xFFBB2BC5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📄 File Row
  Widget _buildFileItem(String title, String size, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: kTextSecondary),
        ],
      ),
    );
  }

  // 🏷 Filters
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: ["All Files", "Documents", "Images", "Videos"].map((filter) {
          final bool isSelected = filter == "All Files";

          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              backgroundColor: kCardColor,
              selectedColor: const Color(0xFF6A5CFF),
              side: BorderSide.none,
              onSelected: (_) {},
            ),
          );
        }).toList(),
      ),
    );
  }
}
