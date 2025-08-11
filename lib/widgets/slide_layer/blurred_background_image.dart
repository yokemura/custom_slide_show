import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'image_display.dart';

// ブラー効果付き背景画像
class BlurredBackgroundImage extends StatelessWidget {
  final String imagePath;
  final double scale;
  
  const BlurredBackgroundImage({
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
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: ImageDisplay(
              imagePath: imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
