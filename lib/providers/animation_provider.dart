import 'package:flutter/material.dart';
import '../slide_item.dart';

// パンアニメーションの初期値と終端値を計算するヘルパー関数
Offset calculatePanOffset(SlideItem slide, Size screenSize) {
  if (slide.pan == null) {
    return Offset.zero;
  }

  final scale = slide.scale ?? 1.0;
  final scaledWidth = screenSize.width * scale;
  final scaledHeight = screenSize.height * scale;
  
  // 初期オフセット（パン開始位置）
  double startX = 0;
  double startY = 0;

  switch (slide.pan!) {
    case PanDirection.up:
      startY = (scaledHeight - screenSize.height) / 2;
      break;
    case PanDirection.down:
      startY = -(scaledHeight - screenSize.height) / 2;
      break;
    case PanDirection.left:
      startX = (scaledWidth - screenSize.width) / 2;
      break;
    case PanDirection.right:
      startX = -(scaledWidth - screenSize.width) / 2;
      break;
  }

  // カスタムオフセットがある場合は適用
  if (slide.xoffset != null) {
    startX += slide.xoffset!;
  }
  if (slide.yoffset != null) {
    startY += slide.yoffset!;
  }

  return Offset(startX, startY);
}

Offset calculatePanEndOffset(SlideItem slide, Size screenSize) {
  if (slide.pan == null) {
    return Offset.zero;
  }

  final scale = slide.scale ?? 1.0;
  final scaledWidth = screenSize.width * scale;
  final scaledHeight = screenSize.height * scale;
  
  double endX = 0;
  double endY = 0;

  switch (slide.pan!) {
    case PanDirection.up:
      endY = -(scaledHeight - screenSize.height) / 2;
      break;
    case PanDirection.down:
      endY = (scaledHeight - screenSize.height) / 2;
      break;
    case PanDirection.left:
      endX = -(scaledWidth - screenSize.width) / 2;
      break;
    case PanDirection.right:
      endX = (scaledWidth - screenSize.width) / 2;
      break;
  }

  // カスタムオフセットがある場合は適用
  if (slide.xoffset != null) {
    endX += slide.xoffset!;
  }
  if (slide.yoffset != null) {
    endY += slide.yoffset!;
  }

  return Offset(endX, endY);
} 