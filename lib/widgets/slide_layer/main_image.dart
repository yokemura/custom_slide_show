import 'package:flutter/material.dart';
import 'image_display.dart';

// メイン画像表示
class MainImage extends StatelessWidget {
  final String imagePath;
  final double scale;
  
  const MainImage({
    super.key,
    required this.imagePath,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: ImageDisplay(
            imagePath: imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
