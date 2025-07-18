import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show RawKeyboard, RawKeyDownEvent, LogicalKeyboardKey, MethodChannel;
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'slideshow_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Slide Show',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Custom Slide Show'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedFolderPath;
  List<Map<String, dynamic>> slideshowData = [];
  bool isLoading = false;
  static const MethodChannel _channel =
      MethodChannel('custom_slide_show/file_picker');

  @override
  void initState() {
    super.initState();
    // Set up keyboard shortcuts
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // Listen for Cmd+O shortcut
    RawKeyboard.instance.addListener((event) {
      if (event is RawKeyDownEvent) {
        if (event.isMetaPressed &&
            event.logicalKey == LogicalKeyboardKey.keyO) {
          _openFolder();
        }
      }
    });
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
                      children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing folder...'),
            ],
        ),
      );
    }

    if (selectedFolderPath == null) {
      return DropTarget(
        onDragDone: (detail) async {
          if (detail.files.isNotEmpty) {
            final file = detail.files.first;
            final filePath = file.path;
            
            // Check if it's a directory
            final directory = Directory(filePath);
            if (await directory.exists()) {
              await _processSelectedFolder(filePath);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please drop a folder, not a file'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          }
        },
        onDragEntered: (detail) {
          // Drag entered
        },
        onDragExited: (detail) {
          // Drag exited
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.withOpacity(0.05),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No folder selected',
                      style: TextStyle(
                        fontSize: 18, 
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Drag and drop a folder with images here\nor click the button below',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Folder'),
              ),
            ],
          ),
        ),
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
                    final imageName = item['image'] as String;

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
          slideshowData = data.cast<Map<String, dynamic>>();
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
          builder: (context) => SlideshowView(
            folderPath: selectedFolderPath!,
            slideshowData: slideshowData,
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

      // Create JSON structure
      final slideshowData = imageFiles
          .map((imageFile) => {
                'image': imageFile,
              })
          .toList();

      // Convert to JSON with pretty formatting
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(slideshowData);
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
