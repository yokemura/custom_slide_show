import 'package:flutter/material.dart';
import '../tategaki.dart';
import '../slide_item.dart';

class CaptionDisplay extends StatelessWidget {
  final CaptionState? captionState;

  const CaptionDisplay({
    super.key,
    required this.captionState,
  });

  // キャプションの表示テキストを取得
  String? get _displayText {
    return captionState?.when(
      show: (text) => text,
      hide: () => null,
      keep: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
        
        // キャプションが表示されない場合は何も表示しない
        if (_displayText == null) {
          return const SizedBox.shrink();
        }

        // テキストの内容に応じて幅を計算
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: clampedFontSize,
          fontWeight: FontWeight.normal,
          height: 1.5,
        );
        final calculatedWidth = Tategaki.calculateWidth(_displayText!, textStyle, space, captionHeight);
        
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
                _displayText!,
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