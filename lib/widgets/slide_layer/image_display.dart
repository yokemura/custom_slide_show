import 'package:flutter/material.dart';
import 'dart:io';
import 'image_error_widget.dart';

// 画像表示の共通ロジック
class ImageDisplay extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  
  const ImageDisplay({
    super.key,
    required this.imagePath,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(imagePath),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const ImageErrorWidget();
      },
    );
  }
}
