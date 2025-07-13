import 'package:flutter/material.dart';
import 'vertical_rotated.dart';

class Tategaki extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double space;

  const Tategaki(this.text, {this.style, this.space = 4, super.key});

  @override
  Widget build(BuildContext context) {
    final mergeStyle = DefaultTextStyle.of(context).style.merge(style);
    return LayoutBuilder(
      builder: (context, constraints) {
        print('DEBUG: Tategaki build - constraints: $constraints');
        print('DEBUG: Tategaki build - text: "$text"');
        print('DEBUG: Tategaki build - style fontSize: ${mergeStyle.fontSize}');
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
    
    // デバッグ情報を出力
    print('DEBUG: Tategaki paint - text length: ${runes.length}');
    print('DEBUG: Tategaki paint - fontSize: $fontSize');
    print('DEBUG: Tategaki paint - size: $size');
    print('DEBUG: Tategaki paint - columnCount: $columnCount');
    print('DEBUG: Tategaki paint - rowCount: $rowCount');

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
        
        // デバッグ情報を出力（最初の数文字のみ）
        if (x < 2 && y < 2) {
          print('DEBUG: Tategaki paint char - char: "$char", offset: $offset, fontSize: $fontSize');
        }
        
        tp.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 