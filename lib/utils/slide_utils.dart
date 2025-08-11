import 'package:flutter/material.dart';
import '../slide_item.dart';

// スライド関連のユーティリティ関数
class SlideUtils {
  // パン開始オフセットを計算
  static Offset calculatePanOffset(SlideItem slide) {
    if (slide.pan == null) {
      return Offset.zero;
    }

    final scale = slide.scale ?? 1.0;
    final xoffset = slide.xoffset ?? 0.0;
    final yoffset = slide.yoffset ?? 0.0;
    
    // 相対値計算（以前の実装と同じ）
    final panAmount = (scale - 1.0);
    
    double startX = xoffset;
    double startY = yoffset;

    switch (slide.pan!) {
      case PanDirection.up:
        startY = yoffset - panAmount * 0.5;
        break;
      case PanDirection.down:
        startY = yoffset + panAmount * 0.5;
        break;
      case PanDirection.left:
        startX = xoffset - panAmount * 0.5;
        break;
      case PanDirection.right:
        startX = xoffset + panAmount * 0.5;
        break;
    }

    return Offset(startX, startY);
  }
  
  // パン終了オフセットを計算
  static Offset calculatePanEndOffset(SlideItem slide) {
    if (slide.pan == null) {
      return Offset.zero;
    }

    final scale = slide.scale ?? 1.0;
    final xoffset = slide.xoffset ?? 0.0;
    final yoffset = slide.yoffset ?? 0.0;
    
    // 相対値計算（以前の実装と同じ）
    final panAmount = (scale - 1.0);
    
    double endX = xoffset;
    double endY = yoffset;

    switch (slide.pan!) {
      case PanDirection.up:
        endY = yoffset + panAmount * 0.5;
        break;
      case PanDirection.down:
        endY = yoffset - panAmount * 0.5;
        break;
      case PanDirection.left:
        endX = xoffset + panAmount * 0.5;
        break;
      case PanDirection.right:
        endX = xoffset - panAmount * 0.5;
        break;
    }

    return Offset(endX, endY);
  }
}
