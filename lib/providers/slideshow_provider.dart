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
  void initialize(List<SlideItem> slideshowData, {int? startIndex}) {
    final initialIndex = startIndex ?? 0;
    final clampedIndex = initialIndex.clamp(0, slideshowData.length - 1);
    final initialSlide = slideshowData.isNotEmpty ? slideshowData[clampedIndex] : null;
    final initialCaption = initialSlide != null ? _getCaptionText(initialSlide, '') : '';
    
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
      final newCaption = _getCaptionText(nextSlide, state.currentCaption);
      
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
      final newCaption = _getCaptionText(previousSlide, '');
      
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
      final newCaption = _getCaptionText(targetSlide, '');
      
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
    final newCaption = currentSlide != null ? _getCaptionText(currentSlide, state.currentCaption) : '';
    
    state = state.copyWith(
      slideshowData: slideshowData,
      currentIndex: clampedIndex,
      currentCaption: newCaption,
    );
  }
}

// プロバイダーの定義
final slideshowProvider = StateNotifierProvider.autoDispose<SlideshowNotifier, SlideshowState>(
  (ref) => SlideshowNotifier(),
); 