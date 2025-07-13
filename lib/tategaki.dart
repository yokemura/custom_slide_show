import 'package:flutter/material.dart';
import 'vertical_rotated.dart';

class Tategaki extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double space;

  const Tategaki(this.text, {this.style, this.space = 4, super.key});

  // テキストの幅を計算する静的メソッド
  static double calculateWidth(String text, TextStyle style, double space, double height) {
    final runes = text.runes.toList();
    final fontSize = style.fontSize ?? 20;
    final columnCount = (height / fontSize).floor();
    final rowCount = (runes.length / columnCount).ceil();
    
    // 縦書きの場合、幅は行数 × (フォントサイズ + 文字間隔)
    return rowCount * (fontSize + space);
  }

  @override
  Widget build(BuildContext context) {
    final mergeStyle = DefaultTextStyle.of(context).style.merge(style);
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _TategakiPainter(text, mergeStyle, space),
          ),
        );
      },
    );
  }
}

class _TategakiPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double space;

  _TategakiPainter(this.text, this.style, this.space);

  @override
  void paint(Canvas canvas, Size size) {
    final runes = text.runes.toList();
    final fontSize = style.fontSize ?? 20;
    final columnCount = (size.height / fontSize).floor();
    final rowCount = (runes.length / columnCount).ceil();

    for (int x = 0; x < rowCount; x++) {
      for (int y = 0; y < columnCount; y++) {
        final charIndex = x * columnCount + y;
        if (charIndex >= runes.length) return;
        String char = String.fromCharCode(runes[charIndex]);
        if (VerticalRotated.map[char] != null) {
          char = VerticalRotated.map[char]!;
        }
        final span = TextSpan(style: style, text: char);
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();
        
        final offset = Offset(
          (size.width - (x + 1) * (fontSize + space)),
          y * fontSize,
        );
        
        tp.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 