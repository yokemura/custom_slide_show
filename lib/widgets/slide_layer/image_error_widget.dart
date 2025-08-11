import 'package:flutter/material.dart';

// 画像読み込みエラー時の表示ウィジェット
class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}
