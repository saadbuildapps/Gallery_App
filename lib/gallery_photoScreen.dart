import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_app/detailScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// ------------------ Gallery Screen ------------------
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];
  Set<int> selectedIndexes = {};

  Future<void> _pickImage(ImageSource source) async {
    final pickFile = await _picker.pickImage(source: source);

    if (pickFile != null) {
      setState(() {
        images.add(File(pickFile.path));
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        images.addAll(pickedFiles.map((files) => File(files.path)).toList());
      });
    }
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void deleteSelected() {
    setState(() {
      images = [
        for (int i = 0; i < images.length; i++)
          if (!selectedIndexes.contains(i)) images[i],
      ];
      selectedIndexes.clear();
    });
  }

  void deleteSingle(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          selectedIndexes.isEmpty
              ? "My Gallery"
              : "${selectedIndexes.length} selected",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (selectedIndexes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: deleteSelected,
            ),
        ],
      ),
      body: images.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Images Yet!',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some photos to get started',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndexes.contains(index);

                  return GestureDetector(
                    onTap: () {
                      if (selectedIndexes.isNotEmpty) {
                        toggleSelection(index);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              imageFile: images[index],
                              tag: "img$index",
                              onDelete: () => deleteSingle(index),
                            ),
                          ),
                        );
                      }
                    },
                    onLongPress: () => toggleSelection(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 3)
                            : Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Stack(
                        children: [
                          Hero(
                            tag: "img$index",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 50,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == "camera") {
            _pickImage(ImageSource.camera);
          } else if (value == "single_gallery") {
            _pickImage(ImageSource.gallery);
          } else {
            _pickMultipleImages();
          }
        },
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "camera",
            child: Row(
              children: [
                const Icon(Icons.camera_alt, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  "Take Photo",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: "single_gallery",
            child: Row(
              children: [
                const Icon(Icons.photo, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  "Pick Single",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: "multi_gallery",
            child: Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  "Pick Multiple",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
