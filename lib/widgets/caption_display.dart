import 'package:flutter/material.dart';
import '../tategaki.dart';

class CaptionDisplay extends StatelessWidget {
  final String caption;

  const CaptionDisplay({
    super.key,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // キャプションが空の場合は何も表示しない
        if (caption.isEmpty) {
          return const SizedBox.shrink();
        }

        // ウィンドウの横幅に比例してフォントサイズを計算
        // 横幅2048pxのときに32ptになるように設定
        final windowWidth = MediaQuery.of(context).size.width;
        final windowHeight = MediaQuery.of(context).size.height;
        final fontSize = (windowWidth / 2048.0) * 32.0;
        
        // 最小・最大フォントサイズを設定
        final clampedFontSize = fontSize.clamp(16.0, 48.0);
        
        // 文字間隔もフォントサイズに比例して調整
        final space = (clampedFontSize / 32.0) * 6.0;
        
        // 縦幅を画面の90%に設定
        final captionHeight = windowHeight * 0.9;
        
        // テキストの内容に応じて幅を計算
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: clampedFontSize,
          fontWeight: FontWeight.normal,
          height: 1.5,
        );
        final calculatedWidth = Tategaki.calculateWidth(caption, textStyle, space, captionHeight);
        
        // 最小幅と最大幅を設定
        final minWidth = clampedFontSize * 1.5; // 最小幅
        final maxWidth = clampedFontSize * 4; // 最大幅
        final finalWidth = calculatedWidth.clamp(minWidth, maxWidth);
        
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: finalWidth, // テキストの内容に応じて動的に計算された幅
              height: captionHeight, // 画面の縦幅の90%
              child: Tategaki(
                caption,
                style: textStyle,
                space: space, // 文字間隔
              ),
            ),
          ),
        );
      },
    );
  }
} 