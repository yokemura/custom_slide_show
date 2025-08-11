import 'package:flutter/material.dart';
import '../slideshow_repository.dart';
import '../slide_item.dart';

class SlideshowScreenViewModel extends ChangeNotifier {
  // ストアドプロパティ
  final SlideshowRepository _repository;
  int _currentSlideIndex = 0;
  String _currentCaption = '';
  
  // コンストラクタ
  SlideshowScreenViewModel(this._repository);
  
  // ゲッター
  SlideshowRepository get repository => _repository;
  int get currentSlideIndex => _currentSlideIndex;
  String get currentCaption => _currentCaption;
  
  // computed property（repositoryのslideshowDataを中継）
  List<SlideItem> get slideshowData => _repository.getSlideshowData();
  
  // その他のcomputed properties
  int get totalSlides => slideshowData.length;
  bool get hasNextSlide => _currentSlideIndex < totalSlides - 1;
  bool get hasPreviousSlide => _currentSlideIndex > 0;
  
  SlideItem? get currentSlide => slideshowData.isNotEmpty && _currentSlideIndex < totalSlides 
      ? slideshowData[_currentSlideIndex] 
      : null;
  
  SlideItem? get nextSlide => hasNextSlide ? slideshowData[_currentSlideIndex + 1] : null;
  
  // キャプションの文字列を取得するヘルパーメソッド
  String _getCaptionText(SlideItem slide, String currentCaption) {
    if (slide.caption == null) {
      return currentCaption; // captionがnullの場合は現在のキャプションを維持
    }
    
    return slide.caption!.when(
      show: (text) => text,
      hide: () => '',
      keep: () => currentCaption,
    );
  }
  
  // スライドショーデータを初期化
  void initialize({int? startIndex}) {
    // repositoryが初期化されていない場合は何もしない
    if (!_repository.isInitialized) return;
    
    final initialIndex = startIndex ?? 0;
    final clampedIndex = initialIndex.clamp(0, slideshowData.length - 1);
    final initialSlide = slideshowData.isNotEmpty ? slideshowData[clampedIndex] : null;
    final initialCaption = initialSlide != null ? _getCaptionText(initialSlide, '') : '';
    
    _currentSlideIndex = clampedIndex;
    _currentCaption = initialCaption;
    notifyListeners();
  }
  
  // 次のスライドに移動
  void goToNextSlide() {
    if (hasNextSlide) {
      final nextIndex = _currentSlideIndex + 1;
      final nextSlide = slideshowData[nextIndex];
      final newCaption = _getCaptionText(nextSlide, _currentCaption);
      
      _currentSlideIndex = nextIndex;
      _currentCaption = newCaption;
      notifyListeners();
    }
  }
  
  // 前のスライドに移動
  void goToPreviousSlide() {
    if (hasPreviousSlide) {
      final previousIndex = _currentSlideIndex - 1;
      final previousSlide = slideshowData[previousIndex];
      final newCaption = _getCaptionText(previousSlide, '');
      
      _currentSlideIndex = previousIndex;
      _currentCaption = newCaption;
      notifyListeners();
    }
  }
  
  // 特定のスライドに移動
  void goToSlide(int index) {
    if (index >= 0 && index < totalSlides) {
      final targetSlide = slideshowData[index];
      final newCaption = _getCaptionText(targetSlide, '');
      
      _currentSlideIndex = index;
      _currentCaption = newCaption;
      notifyListeners();
    }
  }
  
  // スライドショーデータを更新
  void updateSlideshowData(List<SlideItem> newData) async {
    final clampedIndex = _currentSlideIndex.clamp(0, newData.length - 1);
    final currentSlide = newData.isNotEmpty ? newData[clampedIndex] : null;
    final newCaption = currentSlide != null ? _getCaptionText(currentSlide, _currentCaption) : '';
    
    await _repository.saveSlideshowData(newData);
    _currentSlideIndex = clampedIndex;
    _currentCaption = newCaption;
    notifyListeners();
  }
}
