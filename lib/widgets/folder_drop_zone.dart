import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:io'; // Added for Directory

class FolderDropZone extends StatelessWidget {
  const FolderDropZone({
    super.key,
    required this.onFolderSelected,
    required this.onOpenFolder,
  });

  final Future<void> Function(String folderPath) onFolderSelected;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        if (detail.files.isNotEmpty) {
          final file = detail.files.first;
          final filePath = file.path;
          
          // Check if it's a directory
          final directory = Directory(filePath);
          if (await directory.exists()) {
            await onFolderSelected(filePath);
          } else {
            if (context.mounted) {
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
              onPressed: onOpenFolder,
              icon: const Icon(Icons.folder_open),
              label: const Text('Open Folder'),
            ),
          ],
        ),
      ),
    );
  }
}
