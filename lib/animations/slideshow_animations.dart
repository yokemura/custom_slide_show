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
    
    if (scale > 1.0 && pan != null) {
      final currentDuration = slideData.duration ?? displayDuration;
      
      panController.duration = Duration(seconds: currentDuration.round());
      
      final panAmount = (scale - 1.0);
      
      Offset beginOffset;
      Offset endOffset;
      
      switch (pan) {
        case PanDirection.up:
          beginOffset = Offset(0.0, -panAmount * 0.5);
          endOffset = Offset(0.0, panAmount * 0.5);
          break;
        case PanDirection.down:
          beginOffset = Offset(0.0, panAmount * 0.5);
          endOffset = Offset(0.0, -panAmount * 0.5);
          break;
        case PanDirection.left:
          beginOffset = Offset(-panAmount * 0.5, 0.0);
          endOffset = Offset(panAmount * 0.5, 0.0);
          break;
        case PanDirection.right:
          beginOffset = Offset(panAmount * 0.5, 0.0);
          endOffset = Offset(-panAmount * 0.5, 0.0);
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
      
      panController.reset();
      panController.forward();
    } else {
      panAnimation = null;
      _panBeginOffset = null;
    }
  }

  /// 次のスライドのパンアニメーションを準備する（フェードアニメーション用）
  void prepareNextPanAnimation(SlideItem nextSlideData, int displayDuration) {
    final scale = nextSlideData.scale ?? 1.0;
    final pan = nextSlideData.pan;
    
    if (scale > 1.0 && pan != null) {
      final currentDuration = nextSlideData.duration ?? displayDuration;
      
      panController.duration = Duration(seconds: currentDuration.round());
      
      final panAmount = (scale - 1.0);
      
      Offset beginOffset;
      Offset endOffset;
      
      switch (pan) {
        case PanDirection.up:
          beginOffset = Offset(0.0, -panAmount * 0.5);
          endOffset = Offset(0.0, panAmount * 0.5);
          break;
        case PanDirection.down:
          beginOffset = Offset(0.0, panAmount * 0.5);
          endOffset = Offset(0.0, -panAmount * 0.5);
          break;
        case PanDirection.left:
          beginOffset = Offset(-panAmount * 0.5, 0.0);
          endOffset = Offset(panAmount * 0.5, 0.0);
          break;
        case PanDirection.right:
          beginOffset = Offset(panAmount * 0.5, 0.0);
          endOffset = Offset(-panAmount * 0.5, 0.0);
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
      panController.reset();
    } else {
      panAnimation = null;
      _panBeginOffset = null;
    }
  }

  Future<void> executeFadeAnimation() async {
    fadeController.reset();
    await fadeController.forward();
  }

  Offset? getPanOffset(SlideItem slideData, bool isTransitioning, bool isCurrentSlide) {
    final scale = slideData.scale ?? 1.0;
    final pan = slideData.pan;
    
    if (scale <= 1.0 || pan == null) return null;
    
    if (isTransitioning && isCurrentSlide) {
      // フェードアニメーション中の次のスライドは、準備されたアニメーションの初期値を使用
      return _panBeginOffset;
    } else if (!isTransitioning && isCurrentSlide) {
      // フェードアニメーション終了後の現在のスライドは、アニメーションの現在値を使用
      return panAnimation?.value;
    } else {
      // previousIndexの場合はパンの終了位置
      final panAmount = (scale - 1.0);
      switch (pan) {
        case PanDirection.up:
          return Offset(0.0, panAmount * 0.5);
        case PanDirection.down:
          return Offset(0.0, -panAmount * 0.5);
        case PanDirection.left:
          return Offset(panAmount * 0.5, 0.0);
        case PanDirection.right:
          return Offset(-panAmount * 0.5, 0.0);
      }
    }
    
    return null;
  }
} 