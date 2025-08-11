import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, LogicalKeyboardKey, MethodChannel;
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'slideshow_screen.dart';
import '../slide_item.dart';
import '../widgets/folder_drop_zone.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedFolderPath;
  List<SlideItem> slideshowData = [];
  bool isLoading = false;
  static const MethodChannel _channel =
      MethodChannel('custom_slide_show/file_picker');
  
  // Keyboard handler reference
  bool _keyboardHandler(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isMetaPressed &&
          event.logicalKey == LogicalKeyboardKey.keyO) {
        _openFolder();
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    // Set up keyboard shortcuts
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // Listen for Cmd+O shortcut
    HardwareKeyboard.instance.addHandler(_keyboardHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _openFolder,
            tooltip: 'Open Folder',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFolder,
        tooltip: 'Open Folder',
        child: const Icon(Icons.folder_open),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing folder...'),
          ],
        ),
      );
    }

    if (selectedFolderPath == null) {
      return FolderDropZone(
        onFolderSelected: _processSelectedFolder,
        onOpenFolder: _openFolder,
      );
    }

    if (slideshowData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No images found in: ${path.basename(selectedFolderPath!)}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure the folder contains image files',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.folder, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Folder: ${path.basename(selectedFolderPath!)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${slideshowData.length} images',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              // Start slideshow button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: slideshowData.isNotEmpty ? _startSlideshow : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Slide Show'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // Image list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slideshowData.length,
                  itemBuilder: (context, index) {
                    final item = slideshowData[index];
                    final imageName = item.image;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.image, color: Colors.blue),
                        title: Text(imageName),
                        subtitle: Text(
                            'Image ${index + 1} of ${slideshowData.length}'),
                        trailing: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () => _startSlideshowFromIndex(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openFolder() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? result;

      try {
        result = await _channel.invokeMethod<String>('pickFolder');
      } catch (e) {
        result = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select a folder containing images for your slide show',
        );
      }

      if (result != null) {
        await _processSelectedFolder(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _processSelectedFolder(String folderPath) async {
    final slideshowPath = path.join(folderPath, 'slideshow.json');
    final slideshowFile = File(slideshowPath);

    // Check if slideshow.json already exists
    if (await slideshowFile.exists()) {
      await _loadExistingSlideshow(slideshowFile);
      return;
    }

    // Create new slideshow.json
    await _createNewSlideshow(folderPath, slideshowFile);
  }

  Future<void> _loadExistingSlideshow(File slideshowFile) async {
    try {
      final jsonString = await slideshowFile.readAsString();
      final data = json.decode(jsonString) as List;

      if (mounted) {
        setState(() {
          selectedFolderPath = path.dirname(slideshowFile.path);
          slideshowData = data
              .map((item) => SlideItem.fromJson(item as Map<String, dynamic>))
              .toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loaded existing slideshow.json'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading slideshow.json: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startSlideshow() {
    if (selectedFolderPath != null && slideshowData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SlideshowScreen(
            folderPath: selectedFolderPath!,
            slideshowData: slideshowData,
          ),
        ),
      );
    }
  }

  void _startSlideshowFromIndex(int startIndex) {
    if (selectedFolderPath != null && slideshowData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SlideshowScreen(
            folderPath: selectedFolderPath!,
            slideshowData: slideshowData,
            startIndex: startIndex,
          ),
        ),
      );
    }
  }

  Future<void> _createNewSlideshow(
      String folderPath, File slideshowFile) async {
    try {
      final directory = Directory(folderPath);
      final imageExtensions = [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'bmp',
        'tiff',
        'webp'
      ];
      final List<String> imageFiles = [];

      await for (final entity in directory.list()) {
        if (entity is File) {
          final extension =
              path.extension(entity.path).toLowerCase().replaceAll('.', '');
          if (imageExtensions.contains(extension)) {
            imageFiles.add(path.basename(entity.path));
          }
        }
      }

      // Sort files by name (ascending order as in Finder)
      imageFiles.sort();

      // Create SlideItem objects
      final slideshowData = imageFiles
          .map((imageFile) => SlideItem(image: imageFile))
          .toList();

      // Convert to JSON with pretty formatting
      final jsonString = const JsonEncoder.withIndent('  ').convert(
          slideshowData.map((item) => item.toFileJson()).toList());
      await slideshowFile.writeAsString(jsonString);

      if (mounted) {
        setState(() {
          selectedFolderPath = folderPath;
          this.slideshowData = slideshowData;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Created slideshow.json with ${imageFiles.length} images'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating slideshow.json: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
