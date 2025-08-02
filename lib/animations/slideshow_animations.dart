import 'package:flutter/material.dart';
import '../slide_item.dart';

class SlideshowAnimations {
  late AnimationController fadeController;
  late AnimationController slideController;
  late AnimationController panController;
  late Animation<double> fadeAnimation;
  Animation<Offset>? panAnimation;
  Offset? _panBeginOffset;

  SlideshowAnimations(TickerProvider vsync) {
    _initializeControllers(vsync);
  }

  void _initializeControllers(TickerProvider vsync) {
    const int crossfadeDuration = 2; // seconds
    const int displayDuration = 8; // seconds

    fadeController = AnimationController(
      duration: const Duration(milliseconds: crossfadeDuration * 1000),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    ));

    slideController = AnimationController(
      duration: const Duration(milliseconds: crossfadeDuration * 1000),
      vsync: vsync,
    );

    panController = AnimationController(
      duration: const Duration(seconds: displayDuration),
      vsync: vsync,
    );
  }

  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    panController.dispose();
  }

  void startPanAnimation(SlideItem slideData, int displayDuration) {
    final scale = slideData.scale ?? 1.0;
    final pan = slideData.pan;
    final xoffset = slideData.xoffset ?? 0.0;
    final yoffset = slideData.yoffset ?? 0.0;
    
    if (scale > 1.0 && pan != null) {
      final currentDuration = slideData.duration ?? displayDuration;
      
      panController.duration = Duration(seconds: currentDuration.round());
      
      final panAmount = (scale - 1.0);
      
      Offset beginOffset;
      Offset endOffset;
      
      switch (pan) {
        case PanDirection.up:
          beginOffset = Offset(xoffset, yoffset - panAmount * 0.5);
          endOffset = Offset(xoffset, yoffset + panAmount * 0.5);
          break;
        case PanDirection.down:
          beginOffset = Offset(xoffset, yoffset + panAmount * 0.5);
          endOffset = Offset(xoffset, yoffset - panAmount * 0.5);
          break;
        case PanDirection.left:
          beginOffset = Offset(xoffset - panAmount * 0.5, yoffset);
          endOffset = Offset(xoffset + panAmount * 0.5, yoffset);
          break;
        case PanDirection.right:
          beginOffset = Offset(xoffset + panAmount * 0.5, yoffset);
          endOffset = Offset(xoffset - panAmount * 0.5, yoffset);
          break;
      }
      
      _panBeginOffset = beginOffset;
      panAnimation = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: panController,
        curve: Curves.easeInOut,
      ));
      
      try {
        panController.reset();
        panController.forward();
      } catch (e) {
        // コントローラーが既にdisposeされている場合は無視
      }
    } else if (xoffset != 0.0 || yoffset != 0.0) {
      // パンアニメーションがない場合でも、xoffset/yoffsetがある場合は固定オフセットを設定
      final offset = Offset(xoffset, yoffset);
      _panBeginOffset = offset;
      panAnimation = AlwaysStoppedAnimation<Offset>(offset);
    } else {
      panAnimation = null;
      _panBeginOffset = null;
    }
  }

  /// 次のスライドのパンアニメーションを準備する（フェードアニメーション用）
  void prepareNextPanAnimation(SlideItem nextSlideData, int displayDuration) {
    final scale = nextSlideData.scale ?? 1.0;
    final pan = nextSlideData.pan;
    final xoffset = nextSlideData.xoffset ?? 0.0;
    final yoffset = nextSlideData.yoffset ?? 0.0;
    
    if (scale > 1.0 && pan != null) {
      final currentDuration = nextSlideData.duration ?? displayDuration;
      
      panController.duration = Duration(seconds: currentDuration.round());
      
      final panAmount = (scale - 1.0);
      
      Offset beginOffset;
      Offset endOffset;
      
      switch (pan) {
        case PanDirection.up:
          beginOffset = Offset(xoffset, yoffset - panAmount * 0.5);
          endOffset = Offset(xoffset, yoffset + panAmount * 0.5);
          break;
        case PanDirection.down:
          beginOffset = Offset(xoffset, yoffset + panAmount * 0.5);
          endOffset = Offset(xoffset, yoffset - panAmount * 0.5);
          break;
        case PanDirection.left:
          beginOffset = Offset(xoffset - panAmount * 0.5, yoffset);
          endOffset = Offset(xoffset + panAmount * 0.5, yoffset);
          break;
        case PanDirection.right:
          beginOffset = Offset(xoffset + panAmount * 0.5, yoffset);
          endOffset = Offset(xoffset - panAmount * 0.5, yoffset);
          break;
      }
      
      _panBeginOffset = beginOffset;
      panAnimation = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: panController,
        curve: Curves.easeInOut,
      ));
      
      // アニメーションは開始せず、初期状態のみ設定
      try {
        panController.reset();
      } catch (e) {
        // コントローラーが既にdisposeされている場合は無視
      }
    } else if (xoffset != 0.0 || yoffset != 0.0) {
      // パンアニメーションがない場合でも、xoffset/yoffsetがある場合は固定オフセットを設定
      final offset = Offset(xoffset, yoffset);
      _panBeginOffset = offset;
      panAnimation = AlwaysStoppedAnimation<Offset>(offset);
    } else {
      panAnimation = null;
      _panBeginOffset = null;
    }
  }

  Future<void> executeFadeAnimation() async {
    try {
      fadeController.reset();
      await fadeController.forward();
    } catch (e) {
      // コントローラーが既にdisposeされている場合は無視
    }
  }

  void stopAnimations() {
    try {
      fadeController.stop();
    } catch (e) {
      // コントローラーが既にdisposeされている場合は無視
    }
    try {
      slideController.stop();
    } catch (e) {
      // コントローラーが既にdisposeされている場合は無視
    }
    try {
      panController.stop();
    } catch (e) {
      // コントローラーが既にdisposeされている場合は無視
    }
  }

  Offset? getPanOffset(SlideItem slideData, bool isTransitioning, bool isCurrentSlide) {
    final scale = slideData.scale ?? 1.0;
    final pan = slideData.pan;
    final xoffset = slideData.xoffset ?? 0.0;
    final yoffset = slideData.yoffset ?? 0.0;
    
    if (scale <= 1.0 && xoffset == 0.0 && yoffset == 0.0) return null;
    
    Offset panOffset = Offset.zero;
    
    if (scale > 1.0 && pan != null) {
      if (isTransitioning && isCurrentSlide) {
        // フェードアニメーション中の次のスライドは、準備されたアニメーションの初期値を使用
        panOffset = _panBeginOffset ?? Offset.zero;
      } else if (!isTransitioning && isCurrentSlide) {
        // フェードアニメーション終了後の現在のスライドは、アニメーションの現在値を使用
        panOffset = panAnimation?.value ?? Offset.zero;
      } else {
        // previousIndexの場合はパンの終了位置
        final panAmount = (scale - 1.0);
        switch (pan) {
          case PanDirection.up:
            panOffset = Offset(0.0, panAmount * 0.5);
            break;
          case PanDirection.down:
            panOffset = Offset(0.0, -panAmount * 0.5);
            break;
          case PanDirection.left:
            panOffset = Offset(panAmount * 0.5, 0.0);
            break;
          case PanDirection.right:
            panOffset = Offset(-panAmount * 0.5, 0.0);
            break;
        }
      }
    }
    
    // xoffsetとyoffsetを加算
    return panOffset + Offset(xoffset, yoffset);
  }
} 