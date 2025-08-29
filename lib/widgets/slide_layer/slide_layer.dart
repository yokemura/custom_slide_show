import 'package:flutter/material.dart';
import '../../slide_item.dart';
import 'blurred_background_image.dart';
import 'main_image.dart';

// スライドレイヤーウィジェット
class SlideLayer extends StatelessWidget {
  final String imagePath; // folderPathから変更してimagePath（絶対パス）を受け取る
  final SlideItem slideData;
  final Size screenSize;

  const SlideLayer({
    super.key,
    required this.imagePath,
    required this.slideData,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final scale = slideData.scale ?? 1.0;
    
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // Background blurred image
          BlurredBackgroundImage(
            imagePath: imagePath,
            scale: scale,
          ),

          // Main image
          MainImage(
            imagePath: imagePath,
            scale: scale,
          ),
        ],
      ),
    );
  }
}
