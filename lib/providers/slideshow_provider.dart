import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../slide_item.dart';

// スライドショーの状態を管理するクラス
class SlideshowState {
  final List<SlideItem> slideshowData;
  final int currentIndex;

  const SlideshowState({
    required this.slideshowData,
    required this.currentIndex,
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
  }) {
    return SlideshowState(
      slideshowData: slideshowData ?? this.slideshowData,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// スライドショーの状態を管理するプロバイダー
class SlideshowNotifier extends StateNotifier<SlideshowState> {
  SlideshowNotifier() : super(const SlideshowState(slideshowData: [], currentIndex: 0));

  // スライドショーデータを初期化
  void initialize(List<SlideItem> slideshowData, {int? startIndex}) {
    final initialIndex = startIndex ?? 0;
    state = SlideshowState(
      slideshowData: slideshowData,
      currentIndex: initialIndex.clamp(0, slideshowData.length - 1),
    );
  }

  // 次のスライドに移動
  void goToNextSlide() {
    if (state.hasNextSlide) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  // 前のスライドに移動
  void goToPreviousSlide() {
    if (state.hasPreviousSlide) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  // 特定のスライドに移動
  void goToSlide(int index) {
    if (index >= 0 && index < state.totalSlides) {
      state = state.copyWith(currentIndex: index);
    }
  }

  // スライドショーデータを更新
  void updateSlideshowData(List<SlideItem> slideshowData) {
    state = state.copyWith(
      slideshowData: slideshowData,
      currentIndex: state.currentIndex.clamp(0, slideshowData.length - 1),
    );
  }
}

// プロバイダーの定義
final slideshowProvider = StateNotifierProvider<SlideshowNotifier, SlideshowState>(
  (ref) => SlideshowNotifier(),
); 