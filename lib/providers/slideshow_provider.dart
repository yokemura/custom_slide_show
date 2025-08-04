import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../slide_item.dart';

// スライドショーの状態を管理するクラス
class SlideshowState {
  final List<SlideItem> slideshowData;
  final int currentIndex;
  final String currentCaption;

  const SlideshowState({
    required this.slideshowData,
    required this.currentIndex,
    required this.currentCaption,
  });

  // 計算プロパティ
  int get totalSlides => slideshowData.length;
  bool get hasNextSlide => currentIndex < totalSlides - 1;
  bool get hasPreviousSlide => currentIndex > 0;
  
  SlideItem? get currentSlide => 
      slideshowData.isNotEmpty && currentIndex < totalSlides 
          ? slideshowData[currentIndex] 
          : null;
  
  SlideItem? get nextSlide => 
      hasNextSlide ? slideshowData[currentIndex + 1] : null;

  SlideshowState copyWith({
    List<SlideItem>? slideshowData,
    int? currentIndex,
    String? currentCaption,
  }) {
    return SlideshowState(
      slideshowData: slideshowData ?? this.slideshowData,
      currentIndex: currentIndex ?? this.currentIndex,
      currentCaption: currentCaption ?? this.currentCaption,
    );
  }
}

// スライドショーの状態を管理するプロバイダー
class SlideshowNotifier extends StateNotifier<SlideshowState> {
  SlideshowNotifier() : super(const SlideshowState(slideshowData: [], currentIndex: 0, currentCaption: ''));

  // スライドショーデータを初期化
  void initialize(List<SlideItem> slideshowData, {int? startIndex}) {
    final initialIndex = startIndex ?? 0;
    final clampedIndex = initialIndex.clamp(0, slideshowData.length - 1);
    final initialSlide = slideshowData.isNotEmpty ? slideshowData[clampedIndex] : null;
    final initialCaption = initialSlide?.text ?? '';
    
    state = SlideshowState(
      slideshowData: slideshowData,
      currentIndex: clampedIndex,
      currentCaption: initialCaption,
    );
  }

  // 次のスライドに移動
  void goToNextSlide() {
    if (state.hasNextSlide) {
      final nextIndex = state.currentIndex + 1;
      final nextSlide = state.slideshowData[nextIndex];
      // 次のスライドのtextがnullの場合は現在のキャプションを維持
      final newCaption = nextSlide.text ?? state.currentCaption;
      
      state = state.copyWith(
        currentIndex: nextIndex,
        currentCaption: newCaption,
      );
    }
  }

  // 前のスライドに移動
  void goToPreviousSlide() {
    if (state.hasPreviousSlide) {
      final previousIndex = state.currentIndex - 1;
      final previousSlide = state.slideshowData[previousIndex];
      // 前のスライドのtextがnullの場合は空文字列にする
      final newCaption = previousSlide.text ?? '';
      
      state = state.copyWith(
        currentIndex: previousIndex,
        currentCaption: newCaption,
      );
    }
  }

  // 特定のスライドに移動
  void goToSlide(int index) {
    if (index >= 0 && index < state.totalSlides) {
      final targetSlide = state.slideshowData[index];
      // 指定スライドのtextがnullの場合は空文字列にする
      final newCaption = targetSlide.text ?? '';
      
      state = state.copyWith(
        currentIndex: index,
        currentCaption: newCaption,
      );
    }
  }

  // スライドショーデータを更新
  void updateSlideshowData(List<SlideItem> slideshowData) {
    final clampedIndex = state.currentIndex.clamp(0, slideshowData.length - 1);
    final currentSlide = slideshowData.isNotEmpty ? slideshowData[clampedIndex] : null;
    final newCaption = currentSlide?.text ?? '';
    
    state = state.copyWith(
      slideshowData: slideshowData,
      currentIndex: clampedIndex,
      currentCaption: newCaption,
    );
  }
}

// プロバイダーの定義
final slideshowProvider = StateNotifierProvider<SlideshowNotifier, SlideshowState>(
  (ref) => SlideshowNotifier(),
); 