import 'package:flutter/material.dart';
import '../slide_item.dart';
import '../animations/slideshow_animations.dart';

class SlideshowController {
  List<SlideItem> slideshowData;
  final SlideshowAnimations animations;
  final VoidCallback onStateChanged;
  final VoidCallback onCaptionChanged;

  int currentIndex = 0;
  int previousIndex = 0;
  bool isTransitioning = false;
  String? currentCaption;
  bool showCaption = false;
  bool isPaused = false;
  bool isRunning = false;

  // Display settings
  static const int displayDuration = 8; // seconds
  static const int crossfadeDuration = 2; // seconds

  SlideshowController({
    required this.slideshowData,
    required this.animations,
    required this.onStateChanged,
    required this.onCaptionChanged,
  });

  void initialize(int? startIndex) {
    if (startIndex != null && 
        startIndex >= 0 && 
        startIndex < slideshowData.length) {
      currentIndex = startIndex;
    }
    _updateCaption();
  }

  void goToPreviousSlide() {
    if (currentIndex > 0) {
      runSlideshow(currentIndex - 1);
    }
  }

  void goToNextSlide() {
    if (currentIndex < slideshowData.length - 1) {
      runSlideshow(currentIndex + 1);
    }
  }

  void togglePlayPause() {
    if (isPaused) {
      resumeSlideshow();
    } else {
      pauseSlideshow();
    }
  }

  void pauseSlideshow() {
    isPaused = true;
    onStateChanged();
  }

  void resumeSlideshow() {
    if (isPaused) {
      isPaused = false;
      onStateChanged();
      // 現在のスライドからタイマーを再起動
      _restartCurrentSlideTimer();
    }
  }

  void updateSlideshowData(List<SlideItem> newSlideshowData) {
    // スライドショーデータを更新
    slideshowData.clear();
    slideshowData.addAll(newSlideshowData);
    
    // インデックスが範囲外の場合は調整
    if (currentIndex >= slideshowData.length) {
      currentIndex = slideshowData.length - 1;
    }
    if (previousIndex >= slideshowData.length) {
      previousIndex = slideshowData.length - 1;
    }
    
    // キャプションを更新
    _updateCaption();
    
    // 状態変更を通知
    onStateChanged();
  }

  void goToSlide(int slideIndex) {
    if (slideIndex >= 0 && slideIndex < slideshowData.length) {
      // 現在のアニメーションを停止
      animations.stopAnimations();
      
      // インデックスを更新
      previousIndex = currentIndex;
      currentIndex = slideIndex;
      
      // トランジション状態をリセット
      isTransitioning = false;
      
      // キャプションを更新
      _updateCaption();
      
      // 状態変更を通知
      onStateChanged();
      
      // 新しいスライドのアニメーションを開始
      _startPanAnimation();
      
      // 現在のスライドからタイマーを再起動
      _restartCurrentSlideTimer();
    }
  }

  /// スライド表示のアニメーションを指示し、その完了を待つメソッド
  Future<void> runSlideshow([int? slideIndex]) async {
    if (slideshowData.isEmpty) return;

    // インデックスが指定されていない場合は現在のインデックスを使用
    final targetIndex = slideIndex ?? currentIndex;
    
    // 1. 初期状態を確実に設定（最初の呼び出し時のみ）
    if (isTransitioning) {
      isTransitioning = false;
      onStateChanged();
    }

    // 2. 現在のスライドのパンアニメーション開始
    _startPanAnimation();
    
    // スライドショー実行中フラグを設定
    isRunning = true;
    isPaused = false;

    // 3. スライド表示時間待機
    final currentDuration = slideshowData[targetIndex].duration ?? displayDuration;
    await Future.delayed(Duration(seconds: (currentDuration - crossfadeDuration).round()));
    
    // 一時停止中は次のスライドに進まない
    if (isPaused) {
      isRunning = false;
      return;
    }
    
    final nextIndex = targetIndex + 1;
    
    // 最後のスライドの場合は最初に戻る（ループ）
    if (nextIndex >= slideshowData.length) {
      runSlideshow(0); // 最初のスライドから再開
      return;
    }

    // 4. 次のスライドのパンアニメーションを準備
    final nextSlideData = slideshowData[nextIndex];
    animations.prepareNextPanAnimation(nextSlideData, displayDuration);

    // 5. トランジション開始（State更新）
    previousIndex = targetIndex;
    currentIndex = nextIndex;
    isTransitioning = true;
    onStateChanged();

    // 6. キャプション更新
    _updateCaption();

    // 7. フェードアニメーション指示・完了待機
    await animations.executeFadeAnimation();

    // 7. トランジション完了（State更新）
    isTransitioning = false;
    onStateChanged();

    // 8. 次のスライドのパンアニメーション開始
    _startPanAnimation();

    // 9. 再帰的に次のスライドをスケジュール
    runSlideshow(nextIndex);
  }

  void _startPanAnimation() {
    final slideData = slideshowData[currentIndex];
    animations.startPanAnimation(slideData, displayDuration);
  }

  void _restartCurrentSlideTimer() {
    // 現在のスライドのタイマーを再起動
    isRunning = false;
    isPaused = false;
    
    // 少し遅延してからスライドショーを再開（設定変更の確認時間を確保）
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isPaused) {
        // コールバックが呼ばれる前にウィジェットが破棄されている可能性があるため、
        // 安全にコールバックを実行
        try {
          runSlideshow(currentIndex);
        } catch (e) {
          // エラーが発生した場合は無視（ウィジェットが破棄されている可能性）
        }
      }
    });
  }

  // キャプション更新メソッド
  void _updateCaption() {
    if (currentIndex < slideshowData.length) {
      final slideData = slideshowData[currentIndex];
      final text = slideData.text;
      
      if (text == null) {
        // textプロパティが存在しない場合は表示を継続
        // 何もしない（現在のキャプションを維持）
      } else if (text.isEmpty) {
        // 空文字列の場合はキャプション表示を消去
        currentCaption = null;
        showCaption = false;
        onCaptionChanged();
      } else {
        // 新しい文字列の場合はキャプション表示文字列を更新
        currentCaption = text;
        showCaption = true;
        onCaptionChanged();
      }
    }
  }

  SlideItem get currentSlide => slideshowData[currentIndex];
  SlideItem get previousSlideData => slideshowData[previousIndex];
  int get totalSlides => slideshowData.length;
} 