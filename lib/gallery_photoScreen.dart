import 'dart:io';
import 'package:flutter/material.dart';
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

  /// Pick single image (Camera or Gallery)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  /// Pick multiple images from gallery
  Future<void> _pickMultipleImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        images.addAll(pickedFiles.map((file) => File(file.path)).toList());
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          selectedIndexes.isEmpty
              ? "My Gallery"
              : "${selectedIndexes.length} selected",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (selectedIndexes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: deleteSelected,
            ),
        ],
      ),
      body: images.isEmpty
          ? const Center(
              child: Text(
                "No images yet!",
                style: TextStyle(color: Colors.black, fontSize: 33),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
                    child: Stack(
                      children: [
                        Hero(
                          tag: "img$index",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                      ],
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
            _pickMultipleImages(); // ✅ multiple gallery images
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: "camera", child: Text("Take Photo")),
          const PopupMenuItem(
            value: "single_gallery",
            child: Text("Pick Single from Gallery"),
          ),
          const PopupMenuItem(
            value: "multi_gallery",
            child: Text("Pick Multiple from Gallery"),
          ),
        ],
        child: FloatingActionButton(
          onPressed: () {
            _pickMultipleImages();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ------------------ Detail Screen ------------------
class DetailScreen extends StatelessWidget {
  final File imageFile;
  final String tag;
  final VoidCallback onDelete;

  const DetailScreen({
    super.key,
    required this.imageFile,
    required this.tag,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(imageFile, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
